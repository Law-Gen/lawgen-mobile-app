import 'package:equatable/equatable.dart';

import 'chat_session.dart';

class PaginatedChatSessions extends Equatable {
  final List<ChatSession> sessions;
  final int total;
  final int page;
  final int limit;

  const PaginatedChatSessions({
    required this.sessions,
    required this.total,
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [sessions, total, page, limit];
}
