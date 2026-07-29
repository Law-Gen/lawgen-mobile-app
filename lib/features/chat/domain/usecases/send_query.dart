import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/streamed_chat_response.dart';
import '../repository/chat_repository.dart';

class SendQuery {
  final ChatRepository repository;
  SendQuery(this.repository);

  // MODIFIED: Added optional sessionId and pass it to the repository
  Future<Either<Failures, Stream<StreamedChatResponse>>> call({
    required String query,
    required String language,
    String? sessionId,
  }) async {
    return await repository.sendQuery(
      query: query,
      language: language,
      sessionId: sessionId,
    );
  }
}
