// lib/features/profile_and_premium/data/datasources/subscription_local_datasource.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/subscription_status.dart';

abstract class SubscriptionLocalDataSource {
  Future<void> saveSubscription(
      {required String planName, required int durationInDays});
  Future<SubscriptionStatus> getSubscriptionStatus();
  Future<void> cancelSubscription();
}

class SubscriptionLocalDataSourceImpl implements SubscriptionLocalDataSource {
  static const String _planKey = 'subscription_plan';
  static const String _statusKey = 'subscription_status';
  static const String _startDateKey = 'subscription_start_date';
  static const String _endDateKey = 'subscription_end_date';

  @override
  Future<void> saveSubscription(
      {required String planName, required int durationInDays}) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final endDate = now.add(Duration(days: durationInDays));
    await prefs.setString(_planKey, planName);
    await prefs.setString(_statusKey, 'Active');
    await prefs.setString(_startDateKey, now.toIso8601String());
    await prefs.setString(_endDateKey, endDate.toIso8601String());
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final endDateString = prefs.getString(_endDateKey);

    if (endDateString != null &&
        DateTime.now().isAfter(DateTime.parse(endDateString))) {
      await prefs.setString(_statusKey, 'Expired');
    }

    final plan = prefs.getString(_planKey);
    final status = prefs.getString(_statusKey);
    final startDateString = prefs.getString(_startDateKey);
    final endDateStr = prefs.getString(_endDateKey);

    return SubscriptionStatus(
      planName: plan,
      status: status,
      startDate:
          startDateString != null ? DateTime.parse(startDateString) : null,
      endDate: endDateStr != null ? DateTime.parse(endDateStr) : null,
    );
  }

  @override
  Future<void> cancelSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_planKey);
    await prefs.remove(_statusKey);
    await prefs.remove(_startDateKey);
    await prefs.remove(_endDateKey);
  }
}
