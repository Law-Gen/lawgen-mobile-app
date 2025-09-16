import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/paginated_chat_sessions.dart';
import '../repository/chat_repository.dart';

class ListUserChatSessions {
  final ChatRepository repository;

  ListUserChatSessions(this.repository);

  Future<Either<Failures, PaginatedChatSessions>> call() async {
    return await repository.listUserChatSessions();
  }
}
