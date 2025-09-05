import 'package:dartz/dartz.dart';

import '../../../../core/errors/faliures.dart';
import '../entities/message.dart';
import '../repository/chat_repository.dart';

class AskFollowUpUseCase {
  final ChatRepository repository;
  AskFollowUpUseCase(this.repository);

  Future<Either<Failures, void>> call(
    String conversationId,
    String question,
    String language,
  ) {
    return repository.askFollowUpQuestion(conversationId, question, language);
  }
}
