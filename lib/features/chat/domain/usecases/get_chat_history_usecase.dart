import 'package:dartz/dartz.dart';

import '../../../../core/errors/faliures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../repository/chat_repository.dart';

class GetChatHistoryUsecase {
  final ChatRepository repository;

  GetChatHistoryUsecase(this.repository);

  Future<Either<Failures, List<Conversation>>> call() {
    return repository.getChatHistory();
  }
}