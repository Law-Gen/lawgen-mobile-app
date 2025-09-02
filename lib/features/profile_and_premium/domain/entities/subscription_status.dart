// lib/features/profile_and_premium/domain/entities/subscription_status.dart
class SubscriptionStatus {
  final String? planName;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const SubscriptionStatus({
    this.planName,
    this.status,
    this.startDate,
    this.endDate,
  });

  bool get isActive => status == 'Active';
}
