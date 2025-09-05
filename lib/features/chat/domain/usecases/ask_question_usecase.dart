
import 'package:dartz/dartz.dart';

import '../../../../core/errors/faliures.dart';
import '../entities/message.dart';
import '../repository/chat_repository.dart';

class AskQuestionUseCase {
  final ChatRepository repository;

  AskQuestionUseCase(this.repository);

  Future<Either<Failures, void>> call(
    String question,
    String language,
  ) {
    return repository.askQuestion(question, language);
  }
}
