import 'package:dartz/dartz.dart';
import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/legal_document.dart';
import '../../domain/entities/paginated_legal_documents.dart';
import '../../domain/repositories/legal_document_repository.dart';
import '../datasources/legal_document_remote_data_source.dart';

class LegalDocumentRepositoryImpl implements LegalDocumentRepository {
  final LegalDocumentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LegalDocumentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedLegalDocuments>> getLegalDocuments({
    required int page,
    required int pageSize,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteLegalDocuments = await remoteDataSource.getLegalDocuments(
          page: page,
          pageSize: pageSize,
        );
        return Right(remoteLegalDocuments.toEntity());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<LegalDocument>>> getLegalDocumentsByCategoryId({
    required String id,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteDocuments = await remoteDataSource
            .getLegalDocumentsByCategoryId(id: id);
        // Konversikan setiap model ke entitas
        return Right(remoteDocuments.map((model) => model.toEntity()).toList());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
