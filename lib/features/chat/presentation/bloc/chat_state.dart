part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatHistoryLoaded extends ChatState {
  final PaginatedChatSessions sessions;
  const ChatHistoryLoaded(this.sessions);
  @override
  List<Object?> get props => [sessions];
}

class ChatSessionLoaded extends ChatState {
  final String? sessionId;
  final List<Message> messages;
  final bool isStreaming;
  final bool isRecording;
  final Stream<List<int>>? audioStreamToPlay;

  const ChatSessionLoaded({
    this.sessionId,
    required this.messages,
    this.isStreaming = false,
    this.isRecording = false,
    this.audioStreamToPlay,
  });

  @override
  List<Object?> get props => [
    sessionId,
    messages,
    isStreaming,
    isRecording,
    audioStreamToPlay,
  ];

  ChatSessionLoaded copyWith({
    String? sessionId,
    List<Message>? messages,
    bool? isStreaming,
    bool? isRecording,
    Stream<List<int>>? audioStreamToPlay,
    bool clearAudioStream = false,
  }) {
    return ChatSessionLoaded(
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      isRecording: isRecording ?? this.isRecording,
      audioStreamToPlay: clearAudioStream
          ? null
          : audioStreamToPlay ?? this.audioStreamToPlay,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}
