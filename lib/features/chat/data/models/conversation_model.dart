import 'package:hive/hive.dart';
import '../../domain/entities/conversation.dart';
import 'message_model.dart';

part 'conversation_model.g.dart';

@HiveType(typeId: 1)
class ConversationModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final DateTime lastActivityAt;

  ConversationModel({
    required this.id,
    required this.title,
    required this.lastActivityAt,
  });

  ConversationModel copyWith({
    String? id,
    String? title,
    DateTime? lastActivityAt,
  }) => ConversationModel(
    id: id ?? this.id,
    title: title ?? this.title,
    lastActivityAt: lastActivityAt ?? this.lastActivityAt,
  );

  // Convert ConversationModel to Conversation entity
  
  Conversation toEntity(List<MessageModel> messages) {
    return Conversation(
      id: id,
      title: title,
      messages: messages.map((msg) => msg.toEntity()).toList(),
    );
  }
}
