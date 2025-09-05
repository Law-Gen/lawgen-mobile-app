import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';

class ChatDrawer extends StatelessWidget {
  final void Function(String) onSelectConversation;
  final VoidCallback onNewChat;
  final String? activeConversationId;
  const ChatDrawer({
    super.key,
    required this.onSelectConversation,
    required this.onNewChat,
    required this.activeConversationId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: ElevatedButton.icon(
                onPressed: () {
                  // dispatch reset then callback to close and reset page state
                  context.read<ChatBloc>().add(const ResetNewChat());
                  onNewChat();
                },
                icon: const Icon(Icons.add_comment_outlined),
                label: const Text('New Chat'),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (p, c) =>
                    c is ChatLoaded || c is ChatLoading || c is ChatError,
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ChatError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is ChatLoaded) {
                    final convs = state.conversations;
                    if (convs.isEmpty) {
                      return const Center(child: Text('No chats yet'));
                    }
                    return ListView.builder(
                      itemCount: convs.length,
                      itemBuilder: (context, index) {
                        final c = convs[index];
                        final selected = c.id == activeConversationId;
                        return ListTile(
                          selected: selected,
                          splashColor: theme.colorScheme.primary.withOpacity(
                            .1,
                          ),
                          selectedTileColor: theme.colorScheme.surfaceVariant,
                          leading: Icon(
                            Icons.chat_bubble_outline,
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          title: Text(
                            c.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          onTap: () => onSelectConversation(c.id),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'v1.0',
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
