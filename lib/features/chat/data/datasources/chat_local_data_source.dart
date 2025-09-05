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
  Future<List<ConversationModel>> getConversations();
  Future<ConversationModel?> getConversation(String conversationId);
  Future<void> saveConversation(ConversationModel conversation);
  Future<void> deleteConversation(String conversationId);
  Future<void> addMessage(String conversationId, MessageModel message);
  Future<List<MessageModel>> getMessages(String conversationId);
  Future<int> pruneExpired({Duration maxAge = ChatRetentionPolicy.maxAge});
  Future<void> clear();
}

/// Simple skeleton implementation placeholder (replace with Hive/SQLite).
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  bool _initialized = false;
  static const _conversationBoxName = 'conversations_box';
  static const _messagesBoxName = 'messages_box';

  late Box<ConversationModel> _conversationBox;
  late Box<List<MessageModel>> _messagesBox;

  @override
  Future<void> init() async {
    if (_initialized) return;
    // Expect Hive.initFlutter() + adapter registrations done externally (e.g. main.dart)
    _conversationBox = await Hive.openBox<ConversationModel>(
      _conversationBoxName,
    );
    _messagesBox = await Hive.openBox<List<MessageModel>>(_messagesBoxName);
    _initialized = true;
  }

  @override
  Future<void> addMessage(String conversationId, MessageModel message) async {
    final list = _messagesBox.get(conversationId) ?? <MessageModel>[];
    list.add(message);
    await _messagesBox.put(conversationId, list);
    final conv = _conversationBox.get(conversationId);
    if (conv != null) {
      await _conversationBox.put(
        conversationId,
        conv.copyWith(lastActivityAt: DateTime.now()),
      );
    }
  }

  @override
  Future<void> clear() async {
    await _conversationBox.clear();
    await _messagesBox.clear();
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await _conversationBox.delete(conversationId);
    await _messagesBox.delete(conversationId);
  }

  @override
  Future<ConversationModel?> getConversation(String conversationId) async {
    final conv = _conversationBox.get(conversationId);
    if (conv == null) return null;
    if (_isExpired(conv.lastActivityAt)) {
      await deleteConversation(conversationId);
      return null;
    }
    return conv;
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    final now = DateTime.now();
    final convs = _conversationBox.values.toList();
    final filtered = <ConversationModel>[];
    for (final c in convs) {
      if (now.difference(c.lastActivityAt) <= ChatRetentionPolicy.maxAge) {
        filtered.add(c);
      } else {
        // cleanup expired conversation & its messages
        await _conversationBox.delete(c.id);
        await _messagesBox.delete(c.id);
      }
    }
    filtered.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
    return filtered;
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final list = List<MessageModel>.from(
      _messagesBox.get(conversationId) ?? const [],
    );
    if (list.isEmpty) return list;
    final cutoff = DateTime.now().subtract(ChatRetentionPolicy.maxAge);
    final retained = list.where((m) => m.createdAt.isAfter(cutoff)).toList();
    if (retained.length != list.length) {
      await _messagesBox.put(conversationId, retained);
    }
    return retained..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<int> pruneExpired({
    Duration maxAge = ChatRetentionPolicy.maxAge,
  }) async {
    final cutoff = DateTime.now().subtract(maxAge);
    int removedConversations = 0;
    for (final conv in _conversationBox.values.toList()) {
      if (conv.lastActivityAt.isBefore(cutoff)) {
        await deleteConversation(conv.id);
        removedConversations++;
      } else {
        final msgs = _messagesBox.get(conv.id);
        if (msgs != null && msgs.isNotEmpty) {
          final retained = msgs
              .where((m) => m.createdAt.isAfter(cutoff))
              .toList();
          if (retained.length != msgs.length) {
            await _messagesBox.put(conv.id, retained);
          }
        }
      }
    }
    return removedConversations;
  }

  @override
  Future<void> saveConversation(ConversationModel conversation) async {
    await _conversationBox.put(conversation.id, conversation);
  }

  bool _isExpired(DateTime lastActivity) =>
      DateTime.now().difference(lastActivity) > ChatRetentionPolicy.maxAge;
}
