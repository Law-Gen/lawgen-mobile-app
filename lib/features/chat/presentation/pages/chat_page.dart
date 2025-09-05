import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/suggestion_panel.dart';
import '../widgets/message_input.dart';
import '../../domain/entities/message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _activeConversationId; // track current conversation
  StreamSubscription? _stateSub;
  bool _showOfflineBanner = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ChatBloc>();
    final existing = bloc.state;
    if (existing is ChatMessages && existing.messages.isNotEmpty) {
      _activeConversationId = existing.conversationId;
    } else {
      bloc.add(LoadConversations());
    }
    _stateSub = context.read<ChatBloc>().stream.listen((state) {
      // Auto-scroll on new messages
      if (state is ChatMessages) {
        if (state.conversationId != null) {
          _activeConversationId = state.conversationId;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
      if (state is ChatOffline) {
        if (!_showOfflineBanner) {
          _showOfflineBanner = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  context.read<ChatBloc>().add(RetryLastQuestion());
                },
              ),
            ),
          );
        }
      } else {
        if (_showOfflineBanner) {
          // Clear any previously shown snackbar when back online or other state.
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _showOfflineBanner = false;
        }
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _stateSub?.cancel();
    super.dispose();
  }

  void _onSelectConversation(String conversationId) {
    setState(() => _activeConversationId = conversationId);
    context.read<ChatBloc>().add(SetActiveConversation(conversationId));
    Navigator.of(context).maybePop(); // close drawer on selection
  }

  void _onNewChat() {
    setState(() => _activeConversationId = null);
    _textController.clear();
    // State reset handled by ResetNewChat event from drawer.
    Navigator.of(context).maybePop();
  }

  void _onSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    if (_activeConversationId == null) {
      context.read<ChatBloc>().add(SendUserQuestion(question: text));
    } else {
      context.read<ChatBloc>().add(
        SendFollowUpQuestion(
          conversationId: _activeConversationId!,
          question: text,
        ),
      );
    }
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ChatDrawer(
        onSelectConversation: _onSelectConversation,
        onNewChat: _onNewChat,
        activeConversationId: _activeConversationId,
      ),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 72,
      appBar: AppBar(
        title: const Text('Chat'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  BlocBuilder<ChatBloc, ChatState>(
                    buildWhen: (p, c) =>
                        c is ChatMessages ||
                        c is ChatLoading ||
                        c is ChatError ||
                        c is ChatLoaded ||
                        c is ChatOffline,
                    builder: (context, state) {
                      // If we have messages, show them.
                      if (state is ChatMessages) {
                        final messages = state.messages;
                        if (messages.isEmpty && state.conversationId == null) {
                          // Fall back to suggestions when the conversation has no messages yet.
                          return SuggestionPanel(
                            onTapSuggestion: (q) {
                              // Insert only; user must press send.
                              _textController.text = q;
                              _textController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(
                                      offset: _textController.text.length,
                                    ),
                                  );
                              setState(
                                () {},
                              ); // rebuild to keep panel until send
                            },
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final m = messages[index];
                            final isUser = m.role == 'user';
                            return Align(
                              alignment: isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Text(
                                    m.content,
                                    style: TextStyle(
                                      color: isUser
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimary
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      // Offline: show suggestions plus subtle note (snackbar already shown)
                      if (state is ChatOffline) {
                        if (state.messages.isNotEmpty) {
                          final messages = state.messages;
                          return _buildMessageList(messages);
                        }
                        return SuggestionPanel(
                          error: state.message,
                          onTapSuggestion: (q) {
                            _textController.text = q;
                            _textController
                                .selection = TextSelection.fromPosition(
                              TextPosition(offset: _textController.text.length),
                            );
                          },
                        );
                      }
                      // If error show simple message; still allow suggestions.
                      if (state is ChatError) {
                        if (state.messages.isNotEmpty) {
                          return _buildMessageList(
                            state.messages,
                            error: state.message,
                            canRetry: state.canRetry,
                          );
                        }
                        return SuggestionPanel(
                          error: state.message,
                          onTapSuggestion: (q) {
                            _textController.text = q;
                            _textController
                                .selection = TextSelection.fromPosition(
                              TextPosition(offset: _textController.text.length),
                            );
                          },
                        );
                      }
                      // For initial load (ChatInitial, ChatLoading, ChatLoaded with no selection) show suggestions (no spinner).
                      return SuggestionPanel(
                        onTapSuggestion: (q) {
                          _textController.text = q;
                          _textController
                              .selection = TextSelection.fromPosition(
                            TextPosition(offset: _textController.text.length),
                          );
                        },
                      );
                    },
                  ),
                  // Floating retry button overlay when offline
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: BlocSelector<ChatBloc, ChatState, bool>(
                      selector: (state) => state is ChatOffline,
                      builder: (context, isOffline) {
                        if (!isOffline) return const SizedBox.shrink();
                        return FloatingActionButton.extended(
                          heroTag: 'retry_offline',
                          onPressed: () =>
                              context.read<ChatBloc>().add(RetryLastQuestion()),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        );
                      },
                    ),
                  ),
                  // Streaming indicator
                  Positioned(
                    bottom: 16,
                    left: 8,
                    child: BlocBuilder<ChatBloc, ChatState>(
                      buildWhen: (p, c) => c is ChatMessages,
                      builder: (context, state) {
                        if (state is ChatMessages && state.isStreaming) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _TypingIndicator(),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.errorContainer,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                                onPressed: () => context.read<ChatBloc>().add(
                                  CancelStreaming('current'),
                                ),
                                icon: const Icon(Icons.stop),
                                label: const Text('Stop'),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
            MessageInput(controller: _textController, onSend: _onSend),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(
    List<Message> messages, {
    String? error,
    bool canRetry = false,
  }) {
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final m = messages[index];
            final isUser = m.role == 'user';
            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    m.content,
                    style: TextStyle(
                      color: isUser
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (error != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  if (canRetry)
                    TextButton.icon(
                      onPressed: () =>
                          context.read<ChatBloc>().add(RetryLastQuestion()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(width: 4),
            _Dot(delay: 0),
            _Dot(delay: 150),
            _Dot(delay: 300),
            SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.repeat();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(
        begin: 0.6,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        child: CircleAvatar(
          radius: 4,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
