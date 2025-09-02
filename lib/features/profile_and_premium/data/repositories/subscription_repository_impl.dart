// lib/features/profile_and_premium/data/repositories/subscription_repository_impl.dart
import '../../domain/entities/subscription_plan.dart'; // <-- CORRECT IMPORT PATH
import '../../domain/entities/subscription_status.dart'; // <-- CORRECT IMPORT PATH
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_datasource.dart';
import '../datasources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;
  final SubscriptionLocalDataSource localDataSource;

  SubscriptionRepositoryImpl(
      {required this.remoteDataSource, required this.localDataSource});

  @override
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    return const [
      SubscriptionPlan(
          name: 'Pro Monthly',
          price: 100.00,
          durationInDays: 30,
          description: 'Access to all premium features for one month.'),
      SubscriptionPlan(
          name: 'Pro Yearly',
          price: 1000.00,
          durationInDays: 365,
          description: 'Save 20% with an annual subscription.'),
    ];
  }

  @override
  Future<({String checkoutUrl, String txRef})> initializePayment(
      SubscriptionPlan plan, String userId) async {
    final response = await remoteDataSource.initializePayment(
      amount: plan.price,
      email: "test.user@email.com",
      firstName: "Test",
      lastName: "User",
      returnUrl: "https://myapp.com/payment-success",
    );
    final checkoutUrl = response['data']['checkout_url'] as String;
    final txRef = response['data']['tx_ref'] as String;
    return (checkoutUrl: checkoutUrl, txRef: txRef);
  }

  @override
  Future<bool> verifyPayment(String txRef, SubscriptionPlan plan) async {
    final response = await remoteDataSource.verifyTransaction(txRef);
    final isSuccess = response['status'] == 'success' &&
        response['data']?['status'] == 'success';
    if (isSuccess) {
      await localDataSource.saveSubscription(
        planName: plan.name,
        durationInDays: plan.durationInDays,
      );
    }
    return isSuccess;
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async =>
      await localDataSource.getSubscriptionStatus();

  @override
  Future<void> cancelSubscription() async =>
      await localDataSource.cancelSubscription();

  @override
  Future<void> notifyBackend(
          String status, String txRef, String planName, String userId) async =>
      await remoteDataSource.notifyBackend(status, txRef, planName, userId);
}
