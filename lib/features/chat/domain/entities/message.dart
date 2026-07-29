import 'package:equatable/equatable.dart';

import 'source.dart';

class Message extends Equatable {
  final String id;
  final String sessionId;
  final String type;
  final String content;
  final List<Source>? sources;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.content,
    this.sources,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, sessionId, type, content, sources, createdAt];
}
