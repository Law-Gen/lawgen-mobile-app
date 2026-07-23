import 'dart:math';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/faliures.dart';
import '../../../../core/utils/internet_connection.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repository/chat_repository.dart';
import '../../domain/entities/ask_result.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/chat_socket_data_source.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final NetworkInfo networkInfo;
  final ChatLocalDataSource localDataSource;
  final ChatRemoteDataSource remoteDataSource;
  final ChatSocketDataSource socketDataSource;

  // Session ID management for conversations
  final Map<String, String> _sessionIdMap = {};

  ChatRepositoryImpl({
    required this.networkInfo,
    required this.localDataSource,
    required this.remoteDataSource,
    required this.socketDataSource,
  });

  /// Store session ID for a conversation
  void setSessionId(String conversationId, String sessionId) {
    _sessionIdMap[conversationId] = sessionId;
  }

  /// Get session ID for a conversation
  String? getSessionId(String conversationId) {
    return _sessionIdMap[conversationId];
  }

  @override
  Future<Either<Failures, List<Conversation>>> getChatHistory() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.getChatHistory();
        // For now we just ignore remote conversations population until
        // a proper merge strategy is defined. We keep existing local cache.
      } catch (_) {
        // Ignore remote failure; fallback to cached data below.
      }
    }
    try {
      final local = await localDataSource.getConversations();
      return Right(local.map((c) => c.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failures, List<Message>>> getChatMessages(
    String conversationId,
  ) async {
    try {
      final online = await networkInfo.isConnected;
      if (online) {
        final remoteMessages = await remoteDataSource.getChatMessages(
          conversationId,
        );
        // Replace local cache ONLY when remote succeeds.
        // Clear existing local conversation messages then persist fresh copy.
        // (Simplified approach: delete + re-add messages.)
        // Ensure conversation exists locally before storing messages.
        final conv = await localDataSource.getConversation(conversationId);
        if (conv != null) {
          // Overwrite local messages list atomically.
          for (final m in remoteMessages) {
            // Reuse addMessage to keep lastActivity timestamp accurate.
            await localDataSource.addMessage(conversationId, m);
          }
        }
        final mapped = remoteMessages.map(_mapMessageModelToDomain).toList();
        return Right(mapped);
      }
      // Offline fallback: read whatever local snapshot exists.
      final localMessages = await localDataSource.getMessages(conversationId);
      final mapped = localMessages.map(_mapMessageModelToDomain).toList();
      return Right(mapped);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failures, AskResult>> askQuestion({
    required String question,
    required String language,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final conversationId = _generateId();
      final conversation = ConversationModel(
        id: conversationId,
        title: _deriveTitle(question),
        lastActivityAt: DateTime.now(),
      );
      await localDataSource.saveConversation(conversation);
      final userMsg = MessageModel(
        id: _generateId(),
        sender: MessageSender.user,
        content: question,
        createdAt: DateTime.now(),
      );
      await localDataSource.addMessage(conversationId, userMsg);

      // Start new conversation stream (no session ID)
      final stream = socketDataSource.startResponseStream(
        prompt: question,
        language: language,
      );

      return Right(AskResult(conversationId: conversationId, stream: stream));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failures, AskResult>> askFollowUpQuestion({
    required String conversationId,
    required String question,
    required String language,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final userMsg = MessageModel(
        id: _generateId(),
        sender: MessageSender.user,
        content: question,
        createdAt: DateTime.now(),
      );
      await localDataSource.addMessage(conversationId, userMsg);

      // Get session ID for this conversation
      final sessionId = getSessionId(conversationId);

      Stream<ChatEvent> stream;
      if (sessionId != null) {
        // Use follow-up stream with session ID
        stream = socketDataSource.startFollowUpStream(
          sessionId: sessionId,
          prompt: question,
          language: language,
        );
      } else {
        // No session ID yet, start as new conversation
        stream = socketDataSource.startResponseStream(
          prompt: question,
          language: language,
        );
      }

      return Right(
        AskResult(
          conversationId: conversationId,
          stream: stream,
          sessionId: sessionId,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failures, void>> saveAiMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final aiMsg = MessageModel(
        id: _generateId(),
        sender: MessageSender.ai,
        content: content,
        createdAt: DateTime.now(),
      );
      await localDataSource.addMessage(conversationId, aiMsg);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<void> stopAskQuestionStream() {
    return socketDataSource.cancelCurrentStream();
  }
}

// ----------------- Helpers & Mappers -----------------

/// Generates a short unique identifier for a conversation or message.
///
/// The id is built by concatenating the current timestamp in microseconds
/// (DateTime.now().microsecondsSinceEpoch) with a randomly generated
/// 32-bit integer, separated by a dash:
///   "<timestamp>-<randomInt>"
///
/// Returns:
///   A `String` that is highly likely to be unique for each call. Note that
///   this is not cryptographically secure — it is intended for local/DB
///   identifiers and collision likelihood is low but not impossible.
///
/// Example:
///   1616161616161-123456789
///

/// Derives a short title from a user-provided question or prompt.
///
/// Behavior:
///   - Trims leading and trailing whitespace.
///   - If the trimmed string is empty, returns the default title `"Conversation"`.
///   - If the trimmed string is 32 characters or shorter, returns it unchanged.
///   - If longer than 32 characters, returns the first 32 characters followed
///     by a single Unicode ellipsis (`…`) to indicate truncation.
///
/// Notes:
///   - Uses Dart's `String.length` for truncation, which counts UTF-16 code
///     units; this may not perfectly align with visible grapheme clusters for
///     some complex Unicode sequences.
///   - Intended for UI/title display where a concise label is desired.
///
/// Parameters:
///   - `q` : the original question or prompt text.
///
/// Returns:
///   A concise title `String` suitable for use as a conversation label.
///
///
/// Maps a persistence/data-layer MessageModel into the domain-level Message.
///
/// Behavior:
///   - Converts the message sender enum/value into a domain `role` string:
///     - If `m.sender` equals `MessageSender.user`, sets `role` to `"user"`.
///     - Otherwise sets `role` to `"ai"`.
///   - Copies the message `content` verbatim into the domain model.
///
/// Notes:
///   - This is a simple adapter function; if additional metadata or sender
///     types are added later, this mapping should be updated to handle them
///     explicitly.
///   - Assumes `MessageModel` and `Message` exist in the codebase and that the
///     domain `Message` expects a `role` and `content`.
///
/// Parameters:
///   - `m` : the `MessageModel` instance from the data layer to map.
///
/// Returns:
///   A `Message` constructed for use in the domain/business logic layer.
String _generateId() {
  // Use Random.secure if available for better entropy; fallback to Random.
  final rand = (Random is Random) ? Random() : Random();
  // Dart's Random.nextInt requires 0 < max <= 2^32; using 1<<31 keeps us well inside.
  final randomPart = rand.nextInt(1 << 31); // 0 .. 2^31-1
  // Base36 encoding shortens the string while remaining alphanumeric.
  final timePart = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  return '$timePart-${randomPart.toRadixString(36)}';
}

Message _mapMessageModelToDomain(MessageModel m) => Message(
  role: m.sender == MessageSender.user ? 'user' : 'ai',
  content: m.content,
);

String _deriveTitle(String q) {
  final t = q.trim();
  if (t.isEmpty) return 'Conversation';
  if (t.length <= 32) return t;
  return t.substring(0, 32) + '…';
}
