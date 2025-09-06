import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/chat_bloc.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: BlocBuilder<ChatBloc, ChatState>(
          buildWhen: (prev, curr) => true,
          builder: (context, state) {
            bool isStreaming = false;
            bool isPending = false;
            String? conversationId;
            if (state is ChatMessages) {
              isStreaming = state.isStreaming;
              isPending = state.hasPendingUserMessage;
              conversationId = state.conversationId;
            }
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    enabled: !isStreaming, // optional: lock input during stream
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Type your legal question...',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 18,
                      ),
                    ),
                    onSubmitted: (_) {
                      if (!isStreaming && !isPending) onSend();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                if (isStreaming)
                  IconButton.filled(
                    padding: const EdgeInsets.all(12),
                    icon: const Icon(Icons.stop_rounded),
                    onPressed: () {
                      final id = conversationId ?? 'new';
                      context.read<ChatBloc>().add(CancelStreaming(id));
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    tooltip: 'Stop',
                  )
                else if (isPending)
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  IconButton.filled(
                    padding: const EdgeInsets.all(12),
                    icon: const Icon(Icons.send_rounded),
                    onPressed: onSend,
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    tooltip: 'Send',
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
