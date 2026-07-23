import 'package:dartz/dartz.dart';

import '../../../../core/errors/faliures.dart';
import '../entities/message.dart';
import '../repository/chat_repository.dart';

class GetChatMessageUsecase {
  final ChatRepository repository;

  GetChatMessageUsecase(this.repository);

  Future<Either<Failures, List<Message>>> call(String conversationId) {
    return repository.getChatMessages(conversationId);
  }
}