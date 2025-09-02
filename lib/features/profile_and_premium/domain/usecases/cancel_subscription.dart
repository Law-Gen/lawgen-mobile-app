import '../repositories/subscription_repository.dart';

class CancelSubscription {
  final SubscriptionRepository repository;
  CancelSubscription(this.repository);
  Future<void> call() async => await repository.cancelSubscription();
}
