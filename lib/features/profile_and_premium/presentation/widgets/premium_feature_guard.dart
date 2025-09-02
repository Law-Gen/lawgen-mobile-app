// lib/features/profile_and_premium/presentation/widgets/premium_feature_guard.dart
import 'package:flutter/material.dart';
import '../../../../dependency_injection.dart';
import '../../domain/usecases/get_subscription_status.dart';
import '../pages/plans_page.dart';

class PremiumFeatureGuard {
  static Future<void> check(BuildContext context,
      {required VoidCallback onUnlocked}) async {
    final getSubscriptionStatus = sl<GetSubscriptionStatus>();
    final status = await getSubscriptionStatus();

    if (status.isActive) {
      onUnlocked();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Upgrade Required'),
            content: const Text(
                'You need a premium subscription to use this feature.'),
            actions: <Widget>[
              TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop()),
              TextButton(
                child: const Text('Upgrade Now'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PlansPage()));
                },
              ),
            ],
          );
        },
      );
    }
  }
}
