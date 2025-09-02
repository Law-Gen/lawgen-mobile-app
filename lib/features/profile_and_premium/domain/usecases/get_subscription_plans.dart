import '../entities/subscription_plan.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionPlans {
  final SubscriptionRepository repository;
  GetSubscriptionPlans(this.repository);
  Future<List<SubscriptionPlan>> call() async =>
      await repository.getSubscriptionPlans();
}
