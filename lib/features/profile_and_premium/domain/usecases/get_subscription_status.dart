import '../entities/subscription_status.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionStatus {
  final SubscriptionRepository repository;
  GetSubscriptionStatus(this.repository);
  Future<SubscriptionStatus> call() async =>
      await repository.getSubscriptionStatus();
}
