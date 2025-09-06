import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/ask_follow_up_usecase.dart';
import '../../domain/usecases/ask_question_usecase.dart';
// removed AiResponseUsecase (legacy)
import '../../domain/usecases/get_chat_history_usecase.dart';
import '../../domain/usecases/get_chat_message_usecase.dart';
import '../../domain/usecases/stop_ask_question_stream.dart';
import '../../domain/usecases/save_ai_message_usecase.dart';
import '../../../../core/errors/faliures.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatHistoryUsecase getChatHistoryUsecase;
  final GetChatMessageUsecase getChatMessageUsecase;
  final AskQuestionUseCase askQuestionUseCase;
  final AskFollowUpUseCase askFollowUpUseCase;
  final StopAskQuestionStreamUseCase stopStreamUseCase;
  final SaveAiMessageUseCase saveAiMessageUseCase;

  StreamSubscription? _streamSub;
  // Tracks the active conversation id for current user/AI exchange
  String? _currentConversationId;

  ChatBloc({
    required this.getChatHistoryUsecase,
    required this.getChatMessageUsecase,
    required this.askQuestionUseCase,
    required this.askFollowUpUseCase,
    required this.stopStreamUseCase,
    required this.saveAiMessageUseCase,
  }) : super(ChatInitial()) {
    print('[ChatBloc] created');
    on<LoadConversations>(_onLoadConversations);
    on<LoadConversationMessages>(_onLoadConversationMessages);
    on<SendUserQuestion>(_onSendUserQuestion);
    on<SendFollowUpQuestion>(_onSendFollowUpQuestion);
    on<StreamResponseChunk>(_onStreamResponseChunk);
    on<StreamResponseCompleted>(_onStreamResponseCompleted);
    on<StreamResponseError>(_onStreamResponseError);
    on<CancelStreaming>(_onCancelStreaming);
    on<DeleteConversation>(_onDeleteConversation);
    on<PruneExpiredLocalData>(_onPruneExpiredLocalData);
    on<RetryLastQuestion>(_onRetryLastQuestion);
    on<ResetNewChat>(_onResetNewChat);
    on<SetActiveConversation>(_onSetActiveConversation);
    // Internal streaming events (new pattern support)
    on<_StreamResponseChunk>(_onInternalStreamChunk);
    on<_StreamResponseCompleted>(_onInternalStreamCompleted);
    on<_StreamResponseError>(_onInternalStreamError);
  }

  String? _pendingQuestion;
  String? _pendingConversationId;
  bool _pendingIsFollowUp = false;
  List<Message> _currentMessages = [];
  String _streamingBuffer = '';
  String? _lastConversationId;

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    print('[ChatBloc] _onLoadConversations: start');
    emit(ChatLoading());
    final result = await getChatHistoryUsecase();
    result.fold(
      (f) {
        print('[ChatBloc] _onLoadConversations: failure: ${f.messages}');
        emit(ChatError(f.messages));
      },
      (convs) {
        print(
          '[ChatBloc] _onLoadConversations: success, count=${convs.length}',
        );
        emit(ChatLoaded(convs));
        if (_lastConversationId != null) {
          add(LoadConversationMessages(_lastConversationId!));
        }
      },
    );
  }

  Future<void> _onLoadConversationMessages(
    LoadConversationMessages event,
    Emitter<ChatState> emit,
  ) async {
    print(
      '[ChatBloc] _onLoadConversationMessages: conversationId=${event.conversationId}',
    );
    emit(ChatLoading());
    final result = await getChatMessageUsecase(event.conversationId);
    result.fold(
      (f) {
        print('[ChatBloc] _onLoadConversationMessages: failure: ${f.messages}');
        emit(ChatError(f.messages));
      },
      (msgs) {
        print(
          '[ChatBloc] _onLoadConversationMessages: success, messages=${msgs.length}',
        );
        _currentMessages = msgs;
        emit(
          ChatMessages(
            List.unmodifiable(_currentMessages),
            conversationId: event.conversationId,
          ),
        );
      },
    );
  }

  Future<void> _onSendUserQuestion(
    SendUserQuestion event,
    Emitter<ChatState> emit,
  ) async {
    final language = event.language ?? 'en';
    print(
      '[ChatBloc] _onSendUserQuestion: question="${event.question}", language=$language',
    );
    // optimistic user message
    final optimistic = Message(role: 'user', content: event.question);
    _currentMessages = [..._currentMessages, optimistic];
    emit(
      ChatMessages(
        List.unmodifiable(_currentMessages),
        hasPendingUserMessage: true,
        conversationId: null,
      ),
    );

    // Attempt to initiate question (supporting existing signature). If the
    // current askQuestionUseCase returns Either<Failure, Unit>, we keep old
    // flow; if it returns Either<Failure, Stream<String>>, adapt.
    final res = await askQuestionUseCase(event.question, language);
    res.fold(
      (f) {
        print('[ChatBloc] _onSendUserQuestion: failed: ${f.messages}');
        _pendingQuestion = event.question;
        _pendingConversationId = null;
        _pendingIsFollowUp = false;
        if (f is NetworkFailure) {
          emit(
            ChatOffline(
              f.messages,
              messages: List.unmodifiable(_currentMessages),
              isPendingUserMessage: true,
            ),
          );
        } else {
          emit(
            ChatError(
              f.messages,
              messages: List.unmodifiable(_currentMessages),
              canRetry: true,
              isPendingUserMessage: true,
            ),
          );
        }
      },
      (ask) {
        _currentConversationId = ask.conversationId;
        emit(
          ChatMessages(
            List.unmodifiable(_currentMessages),
            hasPendingUserMessage: false,
            isStreaming: true,
            streamingContent: '',
            conversationId: ask.conversationId,
          ),
        );
        _subscribeToStream(ask.stream, ask.conversationId);
      },
    );
  }

  Future<void> _onSendFollowUpQuestion(
    SendFollowUpQuestion event,
    Emitter<ChatState> emit,
  ) async {
    final language = event.language ?? 'en';
    print(
      '[ChatBloc] _onSendFollowUpQuestion: conversationId=${event.conversationId}, question="${event.question}", language=$language',
    );
    // optimistic user message
    final optimistic = Message(role: 'user', content: event.question);
    // track not needed for now
    _currentMessages = [..._currentMessages, optimistic];
    emit(
      ChatMessages(
        List.unmodifiable(_currentMessages),
        hasPendingUserMessage: true,
        conversationId: event.conversationId,
      ),
    );

    final res = await askFollowUpUseCase(
      event.conversationId,
      event.question,
      language,
    );
    res.fold(
      (f) {
        print('[ChatBloc] _onSendFollowUpQuestion: failed: ${f.messages}');
        if (f is NetworkFailure) {
          _pendingQuestion = event.question;
          _pendingConversationId = event.conversationId;
          _pendingIsFollowUp = true;
          emit(
            ChatOffline(
              f.messages,
              messages: List.unmodifiable(_currentMessages),
              isPendingUserMessage: true,
            ),
          );
        } else {
          _pendingQuestion = event.question;
          _pendingConversationId = event.conversationId;
          _pendingIsFollowUp = true;
          emit(
            ChatError(
              f.messages,
              messages: List.unmodifiable(_currentMessages),
              canRetry: true,
              isPendingUserMessage: true,
            ),
          );
        }
      },
      (ask) {
        print('[ChatBloc] streaming follow-up for ${event.conversationId}');
        emit(
          ChatMessages(
            List.unmodifiable(_currentMessages),
            hasPendingUserMessage: false,
            isStreaming: true,
            streamingContent: '',
            conversationId: ask.conversationId,
          ),
        );
        _subscribeToStream(ask.stream, ask.conversationId);
      },
    );
  }

  void _subscribeToStream(Stream<String> stream, String conversationId) {
    _streamSub?.cancel();
    _streamSub = stream.listen(
      (chunk) => add(StreamResponseChunk(conversationId, 'ai-temp', chunk)),
      onError: (e) => add(StreamResponseError(conversationId, e.toString())),
      onDone: () => add(StreamResponseCompleted(conversationId, 'ai-temp')),
      cancelOnError: false,
    );
  }

  // New refactored path when we get a raw Stream<String>
  // (No-op currently; left placeholder for future direct stream integration)

  // Internal (private) streaming events pattern
  void _onInternalStreamChunk(
    _StreamResponseChunk event,
    Emitter<ChatState> emit,
  ) {
    _streamingBuffer += event.chunk;
    final tempList = [
      ..._currentMessages,
      Message(role: 'assistant', content: _streamingBuffer),
    ];
    emit(
      ChatMessages(
        List.unmodifiable(tempList),
        isStreaming: true,
        streamingContent: _streamingBuffer,
        conversationId: _currentConversationId,
      ),
    );
  }

  void _onInternalStreamCompleted(
    _StreamResponseCompleted event,
    Emitter<ChatState> emit,
  ) {
    if (_streamingBuffer.isNotEmpty) {
      final convId = _currentConversationId;
      _currentMessages = [
        ..._currentMessages,
        Message(role: 'assistant', content: _streamingBuffer),
      ];
      if (convId != null) {
        // fire and forget; UI already optimistic
        saveAiMessageUseCase(conversationId: convId, content: _streamingBuffer);
      }
    }
    _streamingBuffer = '';
    emit(
      ChatMessages(
        List.unmodifiable(_currentMessages),
        isStreaming: false,
        conversationId: _currentConversationId,
      ),
    );
    add(LoadConversations());
  }

  void _onInternalStreamError(
    _StreamResponseError event,
    Emitter<ChatState> emit,
  ) {
    emit(
      ChatError(
        event.error,
        messages: List.unmodifiable(_currentMessages),
        canRetry: true,
      ),
    );
  }

  void _onStreamResponseChunk(
    StreamResponseChunk event,
    Emitter<ChatState> emit,
  ) {
    print(
      '[ChatBloc] _onStreamResponseChunk: conversationId=${event.conversationId}, tempId=${event.aiMessageId}, chunk=${event.chunk}',
    );
    // Defensive: ignore end-of-stream sentinel if it reaches here
    final trimmed = event.chunk.trim();
    if (trimmed.toLowerCase() == '[done]') {
      return;
    }
    _streamingBuffer += event.chunk;
    final tempList = [
      ..._currentMessages,
      Message(role: 'assistant', content: _streamingBuffer),
    ];
    emit(
      ChatMessages(
        List.unmodifiable(tempList),
        isStreaming: true,
        streamingContent: _streamingBuffer,
      ),
    );
  }

  void _onStreamResponseCompleted(
    StreamResponseCompleted event,
    Emitter<ChatState> emit,
  ) {
    print(
      '[ChatBloc] _onStreamResponseCompleted: conversationId=${event.conversationId}, tempId=${event.aiMessageId}',
    );
    if (_streamingBuffer.isNotEmpty) {
      final convId = event.conversationId == 'new'
          ? _currentConversationId
          : event.conversationId;
      _currentMessages = [
        ..._currentMessages,
        Message(role: 'assistant', content: _streamingBuffer),
      ];
      if (convId != null) {
        saveAiMessageUseCase(conversationId: convId, content: _streamingBuffer);
      }
    }
    _streamingBuffer = '';
    emit(
      ChatMessages(
        List.unmodifiable(_currentMessages),
        isStreaming: false,
        conversationId: _lastConversationId,
      ),
    );
  }

  void _onStreamResponseError(
    StreamResponseError event,
    Emitter<ChatState> emit,
  ) {
    print(
      '[ChatBloc] _onStreamResponseError: conversationId=${event.conversationId}, error=${event.error}',
    );
    emit(
      ChatError(
        event.error,
        messages: List.unmodifiable(_currentMessages),
        canRetry: true,
      ),
    );
  }

  Future<void> _onCancelStreaming(
    CancelStreaming event,
    Emitter<ChatState> emit,
  ) async {
    print('[ChatBloc] _onCancelStreaming: requested');
    await stopStreamUseCase();
    await _streamSub?.cancel();
    _streamSub = null;
    if (_streamingBuffer.isNotEmpty) {
      _currentMessages = [
        ..._currentMessages,
        Message(role: 'assistant', content: _streamingBuffer),
      ];
      _streamingBuffer = '';
    }
    emit(
      ChatMessages(
        List.unmodifiable(_currentMessages),
        isStreaming: false,
        conversationId: _lastConversationId,
      ),
    );
    print(
      '[ChatBloc] _onCancelStreaming: cancelled and emitted current buffer',
    );
  }

  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<ChatState> emit,
  ) async {
    print(
      '[ChatBloc] _onDeleteConversation: conversationId=${event.conversationId} (TODO: implement deletion)',
    );
    // TODO: implement deletion in repository/local datasource then reload
    // TODO :  SEE IF need this implementation .
  }

  Future<void> _onPruneExpiredLocalData(
    PruneExpiredLocalData event,
    Emitter<ChatState> emit,
  ) async {
    print('[ChatBloc] _onPruneExpiredLocalData: (TODO: implement pruning)');
    // TODO: call local prune via a new use case (not yet added)
    // FIX: implement local data pruning
  }

  Future<void> _onRetryLastQuestion(
    RetryLastQuestion event,
    Emitter<ChatState> emit,
  ) async {
    if (_pendingQuestion == null) return;
    final q = _pendingQuestion!;
    final convo = _pendingConversationId;
    final isFollow = _pendingIsFollowUp;
    _pendingQuestion = null;
    _pendingConversationId = null;
    _pendingIsFollowUp = false;
    if (isFollow && convo != null) {
      add(SendFollowUpQuestion(conversationId: convo, question: q));
    } else {
      add(SendUserQuestion(question: q));
    }
  }

  void _onResetNewChat(ResetNewChat event, Emitter<ChatState> emit) {
    print(
      '[ChatBloc] _onResetNewChat: clearing in-memory messages and pending state',
    );
    _streamSub?.cancel();
    _streamSub = null;
    _streamingBuffer = '';
    _currentMessages = [];
    _pendingQuestion = null;
    _pendingConversationId = null;
    _pendingIsFollowUp = false;
    _lastConversationId = null;
    emit(
      ChatMessages(
        const [],
        hasPendingUserMessage: false,
        conversationId: null,
      ),
    );
  }

  void _onSetActiveConversation(
    SetActiveConversation event,
    Emitter<ChatState> emit,
  ) {
    print('[ChatBloc] _onSetActiveConversation: id=${event.conversationId}');
    _lastConversationId = event.conversationId;
    add(LoadConversationMessages(event.conversationId));
  }

  @override
  Future<void> close() {
    print('[ChatBloc] close: cancelling subscription and closing bloc');
    _streamSub?.cancel();
    return super.close();
  }
}

// Private internal streaming events (new pattern)
class _StreamResponseChunk extends ChatEvent {
  final String chunk;
  const _StreamResponseChunk(this.chunk);
  @override
  List<Object?> get props => [chunk];
}

class _StreamResponseCompleted extends ChatEvent {
  const _StreamResponseCompleted();
}

class _StreamResponseError extends ChatEvent {
  final String error;
  const _StreamResponseError(this.error);
  @override
  List<Object?> get props => [error];
}
