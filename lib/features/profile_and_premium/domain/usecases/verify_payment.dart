import '../entities/subscription_plan.dart';
import '../repositories/subscription_repository.dart';

class VerifyPayment {
  final SubscriptionRepository repository;
  VerifyPayment(this.repository);
  Future<bool> call(String txRef, SubscriptionPlan plan) async =>
      await repository.verifyPayment(txRef, plan);
}
