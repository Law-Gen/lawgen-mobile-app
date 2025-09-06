import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../onboarding_auth/presentation/bloc/auth_bloc.dart';
import '../../../onboarding_auth/presentation/bloc/auth_state.dart';

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
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is Authenticated) {
                    return BlocBuilder<ChatBloc, ChatState>(
                      buildWhen: (p, c) =>
                          c is ChatLoaded || c is ChatLoading || c is ChatError,
                      builder: (context, state) {
                        if (state is ChatLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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
                                splashColor: theme.colorScheme.primary
                                    .withOpacity(.1),
                                selectedTileColor:
                                    theme.colorScheme.surfaceVariant,
                                leading: Icon(
                                  Icons.chat_bubble_outline,
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withOpacity(
                                          0.6,
                                        ),
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
                    );
                  } else {
                    // Unauthenticated: hide history, show info only in main area
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'If you want your conversations to be stored, you need to sign up.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const Divider(height: 1),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is Unauthenticated) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/signup');
                      },
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Sign Up'),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'v1.0',
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
