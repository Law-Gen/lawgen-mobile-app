import '../../domain/entities/chat_session.dart';

class ChatSessionModel extends ChatSession {
  const ChatSessionModel({
    required String id,
    required String userId,
    required String language,
    required DateTime createdAt,
    required DateTime lastActiveAt,
    required bool isGuest,
    required String title,
  }) : super(
         id: id,
         userId: userId,
         language: language,
         createdAt: createdAt,
         lastActiveAt: lastActiveAt,
         isGuest: isGuest,
         title: title,
       );

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'],
      userId: json['user_id'],
      language: json['language'],
      createdAt: DateTime.parse(json['created_at']),
      lastActiveAt: DateTime.parse(json['last_active_at']),
      isGuest: json['is_guest'],
      title: json['title'],
    );
  }
}
