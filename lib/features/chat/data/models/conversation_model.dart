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
  // Store messages directly so you don't have to pass them in during conversion
  @HiveField(3)
  final List<MessageModel> messages;

  ConversationModel({
    required this.id,
    required this.title,
    required this.lastActivityAt,
    this.messages = const [],
  });

  ConversationModel copyWith({
    String? id,
    String? title,
    DateTime? lastActivityAt,
    List<MessageModel>? messages,
  }) => ConversationModel(
        id: id ?? this.id,
        title: title ?? this.title,
        lastActivityAt: lastActivityAt ?? this.lastActivityAt,
        messages: messages ?? this.messages,
      );

  Conversation toEntity() {
    return Conversation(
      id: id,
      title: title,
      messages: messages.map((m) => m.toEntity()).toList(),
    );
  }

 
  
}
