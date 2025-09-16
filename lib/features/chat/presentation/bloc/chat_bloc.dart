import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/message.dart';
import '../../domain/entities/paginated_chat_sessions.dart';
import '../../domain/entities/streamed_chat_response.dart';
import '../../domain/usecases/get_messages_from_session.dart';
import '../../domain/usecases/list_user_chat_sessions.dart';
import '../../domain/usecases/send_query.dart';
import '../../domain/usecases/send_voice_query.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendQuery sendQueryUseCase;
  final ListUserChatSessions listUserChatSessionsUseCase;
  final GetMessagesFromSession getMessagesFromSessionUseCase;
  final SendVoiceQuery sendVoiceQueryUseCase;

  StreamSubscription? _chatStreamSubscription;

  ChatBloc({
    required this.sendQueryUseCase,
    required this.listUserChatSessionsUseCase,
    required this.getMessagesFromSessionUseCase,
    required this.sendVoiceQueryUseCase,
  }) : super(ChatInitial()) {
    on<LoadChatHistory>(_onLoadChatHistory);
    on<StartNewChat>(_onStartNewChat);
    on<LoadChatSession>(_onLoadChatSession);
    on<SendTextMessage>(_onSendTextMessage);
    on<SendVoiceMessage>(_onSendVoiceMessage);
    on<AudioPlaybackFinished>(_onAudioPlaybackFinished);
    on<_ChatStreamEventReceived>(_onChatStreamEventReceived);
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await listUserChatSessionsUseCase();
    result.fold(
      (failure) => emit(ChatError(failure.toString())),
      (sessions) => emit(ChatHistoryLoaded(sessions)),
    );
  }

  void _onStartNewChat(StartNewChat event, Emitter<ChatState> emit) {
    emit(const ChatSessionLoaded(sessionId: null, messages: []));
  }

  Future<void> _onLoadChatSession(
    LoadChatSession event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await getMessagesFromSessionUseCase(event.sessionId);
    result.fold(
      (failure) => emit(ChatError(failure.toString())),
      (messages) => emit(
        ChatSessionLoaded(sessionId: event.sessionId, messages: messages),
      ),
    );
  }

  Future<void> _onSendTextMessage(
    SendTextMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatSessionLoaded) return;
    final currentState = state as ChatSessionLoaded;

    await _chatStreamSubscription?.cancel();

    final userMessage = Message(
      id: 'temp_user_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: currentState.sessionId ?? 'new',
      type: 'user_query',
      content: event.query,
      createdAt: DateTime.now(),
    );
    emit(
      currentState.copyWith(messages: [...currentState.messages, userMessage]),
    );

    final result = await sendQueryUseCase(
      query: event.query,
      language: event.language,
      sessionId: currentState.sessionId,
    );

    result.fold((failure) => emit(ChatError(failure.toString())), (stream) {
      _chatStreamSubscription = stream.listen(
        (response) => add(_ChatStreamEventReceived(response)),
        onError: (error) => emit(ChatError(error.toString())),
        onDone: () {
          if (state is ChatSessionLoaded) {
            emit((state as ChatSessionLoaded).copyWith(isStreaming: false));
          }
        },
      );
    });
  }

  Future<void> _onSendVoiceMessage(
    SendVoiceMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatSessionLoaded) return;
    final currentState = state as ChatSessionLoaded;

    final voiceMessage = Message(
      id: 'temp_voice_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: currentState.sessionId ?? 'new',
      type: 'user_query',
      content: "🎤 Voice Message",
      createdAt: DateTime.now(),
    );
    emit(
      currentState.copyWith(messages: [...currentState.messages, voiceMessage]),
    );

    final result = await sendVoiceQueryUseCase(
      audioFile: event.audioFile,
      language: event.language,
      sessionId: currentState.sessionId,
    );

    result.fold((failure) => emit(ChatError(failure.toString())), (
      audioStream,
    ) {
      emit(currentState.copyWith(audioStreamToPlay: audioStream));
    });
  }

  void _onAudioPlaybackFinished(
    AudioPlaybackFinished event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatSessionLoaded) {
      emit((state as ChatSessionLoaded).copyWith(clearAudioStream: true));
    }
  }

  void _onChatStreamEventReceived(
    _ChatStreamEventReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatSessionLoaded) return;
    final currentState = state as ChatSessionLoaded;
    final response = event.response;

    if (response is SessionId) {
      final aiMessage = Message(
        id: 'temp_ai_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: response.id,
        type: 'llm_response',
        content: '',
        createdAt: DateTime.now(),
      );
      emit(
        currentState.copyWith(
          sessionId: response.id,
          messages: [...currentState.messages, aiMessage],
          isStreaming: true,
        ),
      );
    } else if (response is MessageChunk) {
      final updatedMessages = List<Message>.from(currentState.messages);
      final aiMessageIndex = updatedMessages.lastIndexWhere(
        (m) => m.type == 'llm_response',
      );

      if (aiMessageIndex != -1) {
        final currentAiMessage = updatedMessages[aiMessageIndex];
        final updatedContent = currentAiMessage.content + response.text;
        updatedMessages[aiMessageIndex] = Message(
          id: currentAiMessage.id,
          sessionId: currentAiMessage.sessionId,
          type: currentAiMessage.type,
          content: updatedContent,
          createdAt: currentAiMessage.createdAt,
          sources: response.sources ?? currentAiMessage.sources,
        );
        emit(
          currentState.copyWith(messages: updatedMessages, isStreaming: true),
        );
      }
    } else if (response is StreamComplete) {
      emit(currentState.copyWith(isStreaming: false));
      _chatStreamSubscription?.cancel();
    }
  }

  @override
  Future<void> close() {
    _chatStreamSubscription?.cancel();
    return super.close();
  }
}
