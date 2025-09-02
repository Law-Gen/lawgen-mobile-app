// lib/features/profile_and_premium/presentation/widgets/cancel_subscription_popup.dart
import 'package:flutter/material.dart';
import '../../../../dependency_injection.dart';
import '../../domain/usecases/cancel_subscription.dart';

Future<void> showCancelSubscriptionDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  final CancelSubscription cancelSubscription = sl<CancelSubscription>();

  return showDialog<void>(
    context: context,
    // It's good practice to use a different context name inside the builder
    // to avoid confusion.
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Cancel Subscription'),
        content:
            const Text('Are you sure you want to cancel your subscription?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: const Text('Yes, Cancel'),
            onPressed: () async {
              try {
                // Await the cancellation process
                await cancelSubscription();
              } catch (e) {
                // If something goes wrong, at least print the error
                // In a real app, you might want to show a SnackBar with an error message.
                debugPrint("Failed to cancel subscription: $e");
              }

              // --- THE FIX ---
              // After an async operation, always check if the widget is still
              // mounted before interacting with its context.
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              // --- END OF FIX ---

              // Call the original callback to refresh the UI of the page behind the dialog.
              onConfirm();
            },
          ),
        ],
      );
    },
  );
}
