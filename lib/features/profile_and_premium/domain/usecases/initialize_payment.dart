import '../entities/subscription_plan.dart';
import '../repositories/subscription_repository.dart';

class InitializePayment {
  final SubscriptionRepository repository;
  InitializePayment(this.repository);
  // --- FIX: The return type now matches the repository ---
  Future<({String checkoutUrl, String txRef})> call(
          SubscriptionPlan plan, String userId) async =>
      await repository.initializePayment(plan, userId);
}
