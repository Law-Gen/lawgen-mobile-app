import 'dart:async';
import 'package:hive/hive.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Retention policy: keep at most 30 days of conversations/messages.
class ChatRetentionPolicy {
  static const Duration maxAge = Duration(days: 30);
}

/// Essential local data source API (minimal surface):
/// - init storage
/// - list conversations
/// - get / save a conversation
/// - add & list messages per conversation
/// - prune old data (> 30 days)
/// - delete conversation
/// - clear all
abstract class ChatLocalDataSource {
  Future<void> init();
  Future<void> reInitForUser(String userKey);
  Future<List<ConversationModel>> getConversations();
  Future<ConversationModel?> getConversation(String conversationId);
  Future<void> saveConversation(ConversationModel conversation);
  Future<void> deleteConversation(String conversationId);
  Future<void> addMessage(String conversationId, MessageModel message);
  Future<List<MessageModel>> getMessages(String conversationId);
  Future<int> pruneExpired({Duration maxAge = ChatRetentionPolicy.maxAge});
  Future<void> clear();
  Future<void> purgeAllUserData();
}

/// Simple skeleton implementation placeholder (replace with Hive/SQLite).
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  bool _initialized = false;
  static const _conversationBoxName = 'conversations_box';
  static const _messagesBoxName = 'messages_box';
  String? _userSuffix;

  late Box<ConversationModel> _conversationBox;
  // Use an untyped box for message lists to avoid Hive generic cast issues (List<dynamic> -> List<MessageModel>)
  late Box _messagesBox; // stores values as List<MessageModel>

  @override
  Future<void> init() async {
    if (_initialized) {
      print('[ChatLocalDataSource] init() called but already initialized.');
      return;
    }
    print('[ChatLocalDataSource] Initializing storage... Opening boxes');
    // Expect Hive.initFlutter() + adapter registrations done externally (e.g. main.dart)
    final suffix = _userSuffix ?? 'default';
    _conversationBox = await Hive.openBox<ConversationModel>(
      '${_conversationBoxName}_$suffix',
    );
    _messagesBox = await Hive.openBox('${_messagesBoxName}_$suffix');
    _initialized = true;
    print(
      '[ChatLocalDataSource] Initialization complete. '
      'Conversations: ${_conversationBox.length}, Messages entries: ${_messagesBox.length}',
    );
  }

  @override
  Future<void> reInitForUser(String userKey) async {
    final hashed = _hashUserKey(userKey);
    if (_userSuffix == hashed && _initialized) return;
    if (_initialized) {
      await _conversationBox.close();
      await _messagesBox.close();
      _initialized = false;
    }
    _userSuffix = hashed;
    await init();
    print('[ChatLocalDataSource] Switched to user $_userSuffix');
  }

  @override
  Future<void> addMessage(String conversationId, MessageModel message) async {
    print(
      '[ChatLocalDataSource] Adding message to conversation: $conversationId '
      'at ${message.createdAt}',
    );
    final dynamic raw = _messagesBox.get(conversationId);
    final List<MessageModel> list = (raw is List)
        ? raw.whereType<MessageModel>().toList()
        : <MessageModel>[];
    list.add(message);
    await _messagesBox.put(conversationId, list);
    print(
      '[ChatLocalDataSource] Stored message. Total messages for $conversationId: ${list.length}',
    );
    final conv = _conversationBox.get(conversationId);
    if (conv != null) {
      await _conversationBox.put(
        conversationId,
        conv.copyWith(lastActivityAt: DateTime.now()),
      );
      print(
        '[ChatLocalDataSource] Updated conversation lastActivityAt for $conversationId',
      );
    } else {
      print(
        '[ChatLocalDataSource] Conversation $conversationId not found when adding message.',
      );
    }
  }

  @override
  Future<void> clear() async {
    print('[ChatLocalDataSource] Clearing all conversations and messages...');
    await _conversationBox.clear();
    await _messagesBox.clear();
    print('[ChatLocalDataSource] Clear complete.');
  }

  @override
  Future<void> purgeAllUserData() async {
    print('[ChatLocalDataSource] Purging all user data (logout)');
    if (_initialized) {
      final convName = _conversationBox.name;
      final msgName = _messagesBox.name;
      await _conversationBox.close();
      await _messagesBox.close();
      await Hive.deleteBoxFromDisk(convName);
      await Hive.deleteBoxFromDisk(msgName);
      _initialized = false;
      print('[ChatLocalDataSource] Deleted boxes $convName & $msgName');
    }
    _userSuffix = null;
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    print('[ChatLocalDataSource] Deleting conversation: $conversationId');
    await _conversationBox.delete(conversationId);
    await _messagesBox.delete(conversationId);
    print(
      '[ChatLocalDataSource] Deleted conversation and its messages: $conversationId',
    );
  }

  @override
  Future<ConversationModel?> getConversation(String conversationId) async {
    final conv = _conversationBox.get(conversationId);
    if (conv == null) {
      print(
        '[ChatLocalDataSource] getConversation: $conversationId not found.',
      );
      return null;
    }
    if (_isExpired(conv.lastActivityAt)) {
      print(
        '[ChatLocalDataSource] getConversation: $conversationId expired. Deleting.',
      );
      await deleteConversation(conversationId);
      return null;
    }
    print(
      '[ChatLocalDataSource] getConversation: $conversationId fetched. lastActivityAt=${conv.lastActivityAt}',
    );
    return conv;
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    final now = DateTime.now();
    final convs = _conversationBox.values.toList();
    print(
      '[ChatLocalDataSource] getConversations: fetched ${convs.length} stored conversations.',
    );
    final filtered = <ConversationModel>[];
    for (final c in convs) {
      if (now.difference(c.lastActivityAt) <= ChatRetentionPolicy.maxAge) {
        filtered.add(c);
      } else {
        // cleanup expired conversation & its messages
        print(
          '[ChatLocalDataSource] getConversations: pruning expired conversation ${c.id}',
        );
        await _conversationBox.delete(c.id);
        await _messagesBox.delete(c.id);
      }
    }
    filtered.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
    print(
      '[ChatLocalDataSource] getConversations: returning ${filtered.length} conversations after pruning.',
    );
    return filtered;
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final dynamic raw = _messagesBox.get(conversationId);
    final List<MessageModel> list = (raw is List)
        ? raw.whereType<MessageModel>().toList()
        : <MessageModel>[];
    print(
      '[ChatLocalDataSource] getMessages: conversation $conversationId has ${list.length} stored messages.',
    );
    if (list.isEmpty) return list;
    final cutoff = DateTime.now().subtract(ChatRetentionPolicy.maxAge);
    final retained = list.where((m) => m.createdAt.isAfter(cutoff)).toList();
    if (retained.length != list.length) {
      print(
        '[ChatLocalDataSource] getMessages: pruned ${list.length - retained.length} expired messages for $conversationId',
      );
      await _messagesBox.put(conversationId, retained);
    }
    final sorted = retained..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    print(
      '[ChatLocalDataSource] getMessages: returning ${sorted.length} messages for $conversationId',
    );
    return sorted;
  }

  @override
  Future<int> pruneExpired({
    Duration maxAge = ChatRetentionPolicy.maxAge,
  }) async {
    final cutoff = DateTime.now().subtract(maxAge);
    print(
      '[ChatLocalDataSource] pruneExpired: pruning items older than $cutoff',
    );
    int removedConversations = 0;
    for (final conv in _conversationBox.values.toList()) {
      if (conv.lastActivityAt.isBefore(cutoff)) {
        print(
          '[ChatLocalDataSource] pruneExpired: removing conversation ${conv.id}',
        );
        await deleteConversation(conv.id);
        removedConversations++;
      } else {
        final msgs = _messagesBox.get(conv.id);
        if (msgs != null && msgs.isNotEmpty) {
          final retained = msgs
              .where((m) => m.createdAt.isAfter(cutoff))
              .toList();
          if (retained.length != msgs.length) {
            print(
              '[ChatLocalDataSource] pruneExpired: pruning ${msgs.length - retained.length} messages from ${conv.id}',
            );
            await _messagesBox.put(conv.id, retained);
          }
        }
      }
    }
    print(
      '[ChatLocalDataSource] pruneExpired: removed $removedConversations conversations.',
    );
    return removedConversations;
  }

  @override
  Future<void> saveConversation(ConversationModel conversation) async {
    await _conversationBox.put(conversation.id, conversation);
    print(
      '[ChatLocalDataSource] saveConversation: saved ${conversation.id} lastActivityAt=${conversation.lastActivityAt}',
    );
  }

  bool _isExpired(DateTime lastActivity) =>
      DateTime.now().difference(lastActivity) > ChatRetentionPolicy.maxAge;

  String _hashUserKey(String key) {
    final bytes = key.codeUnits;
    final hash = bytes.fold<int>(0, (a, b) => (a * 31 + b) & 0x7fffffff);
    return hash.toRadixString(16);
  }
}
