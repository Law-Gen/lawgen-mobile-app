// lib/dependency_injection.dart
import 'package:get_it/get_it.dart';
import 'features/profile_and_premium/data/datasources/subscription_local_datasource.dart';
import 'features/profile_and_premium/data/datasources/subscription_remote_datasource.dart';
import 'features/profile_and_premium/data/repositories/subscription_repository_impl.dart';
import 'features/profile_and_premium/domain/repositories/subscription_repository.dart';
import 'features/profile_and_premium/domain/usecases/cancel_subscription.dart';
import 'features/profile_and_premium/domain/usecases/get_subscription_plans.dart';
import 'features/profile_and_premium/domain/usecases/get_subscription_status.dart';
import 'features/profile_and_premium/domain/usecases/initialize_payment.dart';
import 'features/profile_and_premium/domain/usecases/notify_backend.dart';
import 'features/profile_and_premium/domain/usecases/verify_payment.dart';

final sl = GetIt.instance; // sl stands for Service Locator

void init() {
  // Use Cases
  sl.registerLazySingleton(() => GetSubscriptionPlans(sl()));
  sl.registerLazySingleton(() => InitializePayment(sl()));
  sl.registerLazySingleton(() => VerifyPayment(sl()));
  sl.registerLazySingleton(() => GetSubscriptionStatus(sl()));
  sl.registerLazySingleton(() => CancelSubscription(sl()));
  sl.registerLazySingleton(() => NotifyBackend(sl()));

  // Repository
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<SubscriptionRemoteDataSource>(
      () => SubscriptionRemoteDataSourceImpl());
  sl.registerLazySingleton<SubscriptionLocalDataSource>(
      () => SubscriptionLocalDataSourceImpl());
}
