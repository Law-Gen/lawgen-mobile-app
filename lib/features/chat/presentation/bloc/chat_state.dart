part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {}

// chat loading state
final class ChatLoading extends ChatState {}

// chat loaded state
final class ChatLoaded extends ChatState {
  final List<Conversation> conversations;

  const ChatLoaded(this.conversations);

  @override
  List<Object> get props => [conversations];
}

final class ChatMessages extends ChatState {
  final List<Message> messages;
  final bool
  hasPendingUserMessage; // an unsent/awaiting server ack user message
  final bool isStreaming; // AI response currently streaming
  final String? streamingContent; // partial accumulated content
  final String? conversationId; // active conversation id (null if brand new)

  const ChatMessages(
    this.messages, {
    this.hasPendingUserMessage = false,
    this.isStreaming = false,
    this.streamingContent,
    this.conversationId,
  });

  @override
  List<Object> get props => [
    messages,
    hasPendingUserMessage,
    isStreaming,
    streamingContent ?? '',
    conversationId ?? '',
  ];
}

// chat error state
final class ChatError extends ChatState {
  final String message;
  final List<Message> messages; // keep already shown messages
  final bool canRetry;
  final bool isPendingUserMessage; // whether last user msg not accepted

  const ChatError(
    this.message, {
    this.messages = const [],
    this.canRetry = false,
    this.isPendingUserMessage = false,
  });

  @override
  List<Object> get props => [message, messages, canRetry, isPendingUserMessage];
}

final class ChatOffline extends ChatState {
  final String message;
  final List<Message> messages;
  final bool isPendingUserMessage;
  const ChatOffline(
    this.message, {
    this.messages = const [],
    this.isPendingUserMessage = false,
  });
  @override
  List<Object> get props => [message, messages, isPendingUserMessage];
}
