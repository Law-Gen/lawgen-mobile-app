import 'package:hive/hive.dart';

import '../../domain/entities/message.dart';

part 'message_model.g.dart';

@HiveType(typeId: 2)
enum MessageSender {
  @HiveField(0)
  user,
  @HiveField(1)
  ai,
}

@HiveType(typeId: 3)
class MessageModel {
  @HiveField(0)
  final String id; // uuid
  @HiveField(1)
  final MessageSender sender;
  @HiveField(2)
  final String content;
  @HiveField(3)
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.sender,
    required this.content,
    required this.createdAt,
  });

  MessageModel copyWith({
    String? id,
    MessageSender? sender,
    String? content,
    DateTime? createdAt,
  }) => MessageModel(
    id: id ?? this.id,
    sender: sender ?? this.sender,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
  // Convert MessageModel to Message entity
  Message toEntity() {
    return Message(
      role: sender == MessageSender.user ? 'user' : 'ai',
      content: content,
    );
  }
}
