import 'dart:math';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/faliures.dart';
import '../../../../core/utils/internet_connection.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repository/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/chat_socket_data_source.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final NetworkInfo networkInfo;
  final ChatLocalDataSource localDataSource;
  final ChatRemoteDataSource remoteDataSource;
  final ChatSocketDataSource socketDataSource;

  ChatRepositoryImpl({
    required this.networkInfo,
    required this.localDataSource,
    required this.remoteDataSource,
    required this.socketDataSource,
  });

  @override
  Future<Either<Failures, List<Conversation>>> getChatHistory() async {
    if (!await networkInfo.isConnected) {
      // Online: read whatever local snapshot exists
      try{
        final remoteconverstaions = await remoteDataSource.getChatHistory();
        // Replace local cache ONLY when remote succeeds.
        // Clear existing local conversations then persist fresh copy.
        // (Simplified approach: delete + re-add conversations.)
        await localDataSource.clearConversations();
        for (final c in remoteconverstaions) {
          await localDataSource.addConversation(c);
        }
        final conversations = await localDataSource.getConversations();
        // to entity conversion
        final entityConversations = conversations.map((c) => c.toEntity()).toList();
        return Right(entityConversations);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }

   
    }   try {
        final conversations = await localDataSource.getConversations();
        // to entity conversion
        final entityConversations = conversations.map((c) => c.toEntity(c.)).toList();
        return Right(conversations);
      } catch (e) {
        return Left(DatabaseFailure(e.toString()));
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
  Future<Either<Failures, void>> askQuestion(
    String question,
    String language,
  ) async {
    try {
      final online = await networkInfo.isConnected;
      if (!online) {
        return const Left(NetworkFailure('No internet connection'));
      }
      final conversationId = _generateId();
      await socketDataSource.startResponseStream(
        conversationId: conversationId,
        prompt: question,
        language: language,
      );
      // Defer local persistence until remote (or stream completion) confirms.
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failures, void>> askFollowUpQuestion(
    String conversationId,
    String question,
    String language,
  ) async {
    try {
      final online = await networkInfo.isConnected;
      if (!online) {
        return const Left(NetworkFailure('No internet connection'));
      }
      await socketDataSource.startResponseStream(
        conversationId: conversationId,
        prompt: question,
        language: language,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failures, String>> aiResponseStream() {
    return socketDataSource.responseStream().map<Either<Failures, String>>(
      (chunk) => Right(chunk),
    );
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
