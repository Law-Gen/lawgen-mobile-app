import 'package:equatable/equatable.dart';

import 'source.dart';

abstract class StreamedChatResponse extends Equatable {
  const StreamedChatResponse();
}

class SessionId extends StreamedChatResponse {
  final String id;

  const SessionId(this.id);

  @override
  List<Object?> get props => [id];
}

class MessageChunk extends StreamedChatResponse {
  final String text;
  final List<Source>? sources;

  const MessageChunk({required this.text, this.sources});

  @override
  List<Object?> get props => [text, sources];
}

class StreamComplete extends StreamedChatResponse {
  final bool isComplete;
  final List<String> suggestedQuestions;

  const StreamComplete({
    required this.isComplete,
    required this.suggestedQuestions,
  });

  @override
  List<Object?> get props => [isComplete, suggestedQuestions];
}
