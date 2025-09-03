import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../core/network/network_info.dart';
import 'data/datasources/legal_document_remote_data_source.dart';
import 'data/repositories/legal_document_repository_impl.dart';
import 'domain/repositories/legal_document_repository.dart';
import 'domain/usecases/get_legal_documents_by_category_id_usecase.dart';
import 'domain/usecases/get_legal_documents_usecase.dart';
import 'presentation/bloc/legal_content_bloc.dart'; // Adjust this path

// Service Locator instance
final catalogSL = GetIt.instance;

Future<void> initCatalog() async {
  //================================================
  // Feature - Legal Content
  //================================================

  //! Bloc
  // Registered as a factory because we might want a new instance for each page
  // that uses it, to avoid cross-state issues.
  catalogSL.registerFactory(
    () => LegalContentBloc(
      getLegalDocuments: catalogSL(),
      getLegalDocumentsByCategoryId: catalogSL(),
    ),
  );

  //! Use cases
  // Registered as lazy singletons because they don't have any state and
  // can be reused across the app.
  catalogSL.registerLazySingleton(() => GetLegalDocumentsUsecase(catalogSL()));
  catalogSL.registerLazySingleton(
    () => GetLegalDocumentsByCategoryIdUsecase(catalogSL()),
  );

  //! Repository
  // We register the implementation (LegalDocumentRepositoryImpl)
  // for the abstract type (LegalDocumentRepository).
  catalogSL.registerLazySingleton<LegalDocumentRepository>(
    () => LegalDocumentRepositoryImpl(
      remoteDataSource: catalogSL(),
      networkInfo: catalogSL(),
    ),
  );

  //! Data sources
  // catalogSL.registerLazySingleton<LegalDocumentRemoteDataSource>(
  //   () => LegalDocumentRemoteDataSourceImpl(
  //     // <--- THIS IS THE REAL ONE
  //     client: catalogSL(),
  //     secureStorage: catalogSL(),
  //   ),
  // );

  catalogSL.registerLazySingleton<LegalDocumentRemoteDataSource>(
    // Use the dummy implementation for testing
    () => DummyLegalDocumentRemoteDataSourceImpl(),
  );

  //================================================
  // Core
  //================================================
  // catalogSL.registerLazySingleton<NetworkInfo>(
  //   () => NetworkInfoImpl(catalogSL()),
  // );

  //================================================
  // External
  //================================================
  // catalogSL.registerLazySingleton(() => http.Client());
  // catalogSL.registerLazySingleton(
  //   () => InternetConnectionChecker.createInstance(),
  // );
  catalogSL.registerLazySingleton(() => const FlutterSecureStorage());
}
