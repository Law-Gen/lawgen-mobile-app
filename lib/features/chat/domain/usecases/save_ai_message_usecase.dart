import 'package:dartz/dartz.dart';

import '../../../../core/errors/faliures.dart';
import '../repository/chat_repository.dart';

class SaveAiMessageUseCase {
  final ChatRepository repository;
  SaveAiMessageUseCase(this.repository);

  Future<Either<Failures, void>> call({
    required String conversationId,
    required String content,
  }) {
    return repository.saveAiMessage(
      conversationId: conversationId,
      content: content,
    );
  }
}
