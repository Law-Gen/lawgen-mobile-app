import '../../domain/entities/paginated_chat_sessions.dart';
import 'chat_session_model.dart';

class PaginatedChatSessionsModel extends PaginatedChatSessions {
  const PaginatedChatSessionsModel({
    required List<ChatSessionModel> sessions,
    required int total,
    required int page,
    required int limit,
  }) : super(sessions: sessions, total: total, page: page, limit: limit);

  factory PaginatedChatSessionsModel.fromJson(Map<String, dynamic> json) {
    // THIS IS THE FIX:
    // 1. Check if the 'sessions' key exists and is not null.
    // 2. If it is, parse it as a list.
    // 3. If it's missing or null, default to an empty list `[]`.
    final sessionsList = json['sessions'] != null
        ? json['sessions'] as List
        : [];

    return PaginatedChatSessionsModel(
      sessions: sessionsList
          .map((session) => ChatSessionModel.fromJson(session))
          .toList(),
      // Also provide default values for other fields in case they are missing
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
    );
  }
}
