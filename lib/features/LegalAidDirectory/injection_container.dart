import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../core/errors/network/network_info.dart';
import 'data/datasources/legal_aid_remote_data_source.dart';
import 'data/repositories/legal_aid_repository_impl.dart';
import 'domain/repositories/legal_aid_repository.dart';
import 'domain/usecases/get_legal_entities_usecase.dart';
import 'presentation/bloc/legal_aid_bloc.dart';

// Use the same GetIt instance from your main container
final LegalAidSL = GetIt.instance;

Future<void> initLegalAid() async {
  //================================================
  // Feature - Legal Aid Directory
  //================================================

  //! Bloc
  // Registered as a factory to ensure a new instance is created every time,
  // resetting the state (like search queries) when the user re-enters the page.
  LegalAidSL.registerFactory(
    () => LegalAidBloc(getLegalEntities: LegalAidSL()),
  );

  //! Use cases
  // Registered as a lazy singleton because it's a stateless class that can be reused.
  LegalAidSL.registerLazySingleton(() => GetLegalEntitiesUsecase(LegalAidSL()));

  //! Repository
  // Registers the implementation for the abstract repository contract.
  LegalAidSL.registerLazySingleton<LegalAidRepository>(
    () => LegalAidRepositoryImpl(
      remoteDataSource: LegalAidSL(),
      networkInfo: LegalAidSL(), // Depends on the core NetworkInfo
    ),
  );

  //! Data sources
  LegalAidSL.registerLazySingleton<LegalAidRemoteDataSource>(
    // CHANGE THIS LINE:
    () => LegalAidRemoteDataSourceImpl(client: LegalAidSL()),

    // TO THIS:
    // () => DummyLegalAidRemoteDataSourceImpl(),
  );

  // // Debug print to confirm registrations
  // print(
  //   'initLegalAid: InternetConnectionChecker registered = ${LegalAidSL.isRegistered<InternetConnectionChecker>()}',
  // );
  // print(
  //   'initLegalAid: NetworkInfo registered = ${LegalAidSL.isRegistered<NetworkInfo>()}',
  // );

  // // Ensure InternetConnectionChecker is registered
  // if (!LegalAidSL.isRegistered<InternetConnectionChecker>()) {
  //   LegalAidSL.registerLazySingleton<InternetConnectionChecker>(
  //     () => InternetConnectionChecker.createInstance(),
  //   );
  // }

  // // Ensure NetworkInfo is registered (important!)
  // if (!LegalAidSL.isRegistered<NetworkInfo>()) {
  //   LegalAidSL.registerLazySingleton<NetworkInfo>(
  //     // adjust constructor if your impl uses positional instead of named parameter
  //     () => NetworkInfoImpl(connectionChecker: LegalAidSL()),
  //   );
  // }
}
