import 'package:dartz/dartz.dart';

import '../../../../core/errors/faliures.dart';
import '../repository/chat_repository.dart';

class AiResponseUsecase {
  final ChatRepository repository;

  AiResponseUsecase(this.repository);

  Stream<Either<Failures, String>> call(
    String conversationId,
    String question,
    String language,
  ) {
    return repository.aiResponseStream(
  
    );
  }
}