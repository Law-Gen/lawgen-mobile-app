part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadChatHistory extends ChatEvent {}

class LoadChatSession extends ChatEvent {
  final String sessionId;
  const LoadChatSession(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}

class StartNewChat extends ChatEvent {}

class SendTextMessage extends ChatEvent {
  final String query;
  final String language;
  const SendTextMessage({required this.query, required this.language});
  @override
  List<Object?> get props => [query, language];
}

class SendVoiceMessage extends ChatEvent {
  final File audioFile;
  final String language;
  const SendVoiceMessage({required this.audioFile, required this.language});
  @override
  List<Object?> get props => [audioFile, language];
}

class AudioPlaybackFinished extends ChatEvent {}

class _ChatStreamEventReceived extends ChatEvent {
  final StreamedChatResponse response;
  const _ChatStreamEventReceived(this.response);
  @override
  List<Object?> get props => [response];
}
