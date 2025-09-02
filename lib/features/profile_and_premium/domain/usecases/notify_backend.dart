import '../repositories/subscription_repository.dart';

class NotifyBackend {
  final SubscriptionRepository repository;
  NotifyBackend(this.repository);
  Future<void> call(
          String status, String txRef, String planName, String userId) async =>
      await repository.notifyBackend(status, txRef, planName, userId);
}
