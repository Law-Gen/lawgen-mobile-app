import 'package:dartz/dartz.dart';

import '../../../../core/errors/faliures.dart';
import '../entities/ask_result.dart';
import '../repository/chat_repository.dart';

class AskQuestionUseCase {
  final ChatRepository repository;

  AskQuestionUseCase(this.repository);

  Future<Either<Failures, AskResult>> call(String question, String language) {
    return repository.askQuestion(question: question, language: language);
  }
}
