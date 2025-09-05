import 'package:flutter/material.dart';

class SuggestionPanel extends StatelessWidget {
  final void Function(String) onTapSuggestion;
  final String? error;
  const SuggestionPanel({super.key, required this.onTapSuggestion, this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = <String>[
      'Explain my contractual rights',
      'Draft a simple NDA',
      'Summarize this legal paragraph',
      'What does this clause mean?',
      'Outline steps to register a business',
      'Help me write a demand letter',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What can I help you with?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(
              error!,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: suggestions.map((s) {
              return GestureDetector(
                onTap: () => onTapSuggestion(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(.3),
                    ),
                  ),
                  child: Text(
                    s,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          Text(
            'Tap a suggestion to start, or type your own question below.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(.8),
            ),
          ),
        ],
      ),
    );
  }
}
