// lib/features/profile_and_premium/domain/entities/subscription_plan.dart
class SubscriptionPlan {
  final String name;
  final double price;
  final int durationInDays;
  final String description;

  const SubscriptionPlan({
    required this.name,
    required this.price,
    required this.durationInDays,
    required this.description,
  });
}
