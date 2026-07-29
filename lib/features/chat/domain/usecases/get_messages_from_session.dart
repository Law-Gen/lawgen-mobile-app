import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/message.dart';
import '../repository/chat_repository.dart';

class GetMessagesFromSession {
  final ChatRepository repository;

  GetMessagesFromSession(this.repository);

  Future<Either<Failures, List<Message>>> call(String sessionId) async {
    return await repository.getMessagesFromSession(sessionId);
  }
}
