// lib/features/profile_and_premium/domain/entities/subscription_plan.dart
class SubscriptionPlan {
  final String name;
  final double price;
  final int durationInDays;
  final String description;
  final List<String> features; // <-- ADD THIS
  final bool isMostPopular; // <-- ADD THIS

  const SubscriptionPlan({
    required this.name,
    required this.price,
    required this.durationInDays,
    required this.description,
    this.features = const [], // <-- ADD THIS
    this.isMostPopular = false, // <-- ADD THIS
  });
}
