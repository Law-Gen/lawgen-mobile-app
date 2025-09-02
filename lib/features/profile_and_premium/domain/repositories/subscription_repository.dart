// lib/features/profile_and_premium/domain/repositories/subscription_repository.dart
import '../entities/subscription_plan.dart';
import '../entities/subscription_status.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlan>> getSubscriptionPlans();
  // --- FIX: This should return a record with both values ---
  Future<({String checkoutUrl, String txRef})> initializePayment(
      SubscriptionPlan plan, String userId);
  Future<bool> verifyPayment(String txRef, SubscriptionPlan plan);
  Future<SubscriptionStatus> getSubscriptionStatus();
  Future<void> cancelSubscription();
  // --- FIX: Added the missing userId parameter ---
  Future<void> notifyBackend(
      String status, String txRef, String planName, String userId);
}
