import 'package:dartz/dartz.dart';

import '../../../../core/errors/faliures.dart';
import '../entities/ask_result.dart';
import '../repository/chat_repository.dart';

class AskFollowUpUseCase {
  final ChatRepository repository;
  AskFollowUpUseCase(this.repository);

  Future<Either<Failures, AskResult>> call(
    String conversationId,
    String question,
    String language,
  ) {
    return repository.askFollowUpQuestion(
      conversationId: conversationId,
      question: question,
      language: language,
    );
  }
}
