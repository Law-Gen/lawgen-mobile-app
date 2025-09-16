import '../../domain/entities/message.dart';
import 'source_model.dart';

class MessageModel extends Message {
  const MessageModel({
    required String id,
    required String sessionId,
    required String type,
    required String content,
    List<SourceModel>? sources,
    required DateTime createdAt,
  }) : super(
         id: id,
         sessionId: sessionId,
         type: type,
         content: content,
         sources: sources,
         createdAt: createdAt,
       );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      sessionId: json['session_id'],
      type: json['type'],
      content: json['content'],
      sources: json['sources'] != null
          ? (json['sources'] as List)
                .map((source) => SourceModel.fromJson(source))
                .toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
