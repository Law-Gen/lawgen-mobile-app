import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message.dart';
import '../entities/paginated_chat_sessions.dart';
import '../entities/streamed_chat_response.dart';

abstract class ChatRepository {
  // MODIFIED: Added optional sessionId
  Future<Either<Failures, Stream<StreamedChatResponse>>> sendQuery({
    required String query,
    required String language,
    String? sessionId,
  });

  Future<Either<Failures, PaginatedChatSessions>> listUserChatSessions();

  Future<Either<Failures, List<Message>>> getMessagesFromSession(
    String sessionId,
  );

  Future<Either<Failures, Stream<List<int>>>> sendVoiceQuery({
    required File audioFile,
    String? sessionId,
    required String language,
  });
}
