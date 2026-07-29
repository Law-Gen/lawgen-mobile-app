import 'package:equatable/equatable.dart';

class ChatSession extends Equatable {
  final String id;
  final String userId;
  final String language;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final bool isGuest;
  final String title;

  const ChatSession({
    required this.id,
    required this.userId,
    required this.language,
    required this.createdAt,
    required this.lastActiveAt,
    required this.isGuest,
    required this.title,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    language,
    createdAt,
    lastActiveAt,
    isGuest,
    title,
  ];
}
