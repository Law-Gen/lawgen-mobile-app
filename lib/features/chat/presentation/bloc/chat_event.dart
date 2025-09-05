part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversations extends ChatEvent {}

class LoadConversationMessages extends ChatEvent {
  final String conversationId;
  const LoadConversationMessages(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

class SendUserQuestion extends ChatEvent {
  final String question;
  final String? language;
  final String? conversationId;
  const SendUserQuestion({
    required this.question,
    this.language,
    this.conversationId,
  });
  @override
  List<Object?> get props => [question, language, conversationId];
}

class SendFollowUpQuestion extends ChatEvent {
  final String conversationId;
  final String question;
  final String? language;
  final String? parentMessageId;
  const SendFollowUpQuestion({
    required this.conversationId,
    required this.question,
    this.language,
    this.parentMessageId,
  });
  @override
  List<Object?> get props => [
    conversationId,
    question,
    language,
    parentMessageId,
  ];
}

class StreamResponseChunk extends ChatEvent {
  final String conversationId;
  final String aiMessageId;
  final String chunk;
  const StreamResponseChunk(this.conversationId, this.aiMessageId, this.chunk);
  @override
  List<Object?> get props => [conversationId, aiMessageId, chunk];
}

class StreamResponseCompleted extends ChatEvent {
  final String conversationId;
  final String aiMessageId;
  const StreamResponseCompleted(this.conversationId, this.aiMessageId);
  @override
  List<Object?> get props => [conversationId, aiMessageId];
}

class StreamResponseError extends ChatEvent {
  final String conversationId;
  final String error;
  const StreamResponseError(this.conversationId, this.error);
  @override
  List<Object?> get props => [conversationId, error];
}

class CancelStreaming extends ChatEvent {
  final String conversationId;
  final String? aiMessageId;
  const CancelStreaming(this.conversationId, {this.aiMessageId});
  @override
  List<Object?> get props => [conversationId, aiMessageId];
}

class DeleteConversation extends ChatEvent {
  final String conversationId;
  const DeleteConversation(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

class PruneExpiredLocalData extends ChatEvent {
  const PruneExpiredLocalData();
}

class RetryLastQuestion extends ChatEvent {
  const RetryLastQuestion();
}

class ResetNewChat extends ChatEvent {
  const ResetNewChat();
}

class SetActiveConversation extends ChatEvent {
  final String conversationId;
  const SetActiveConversation(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}
