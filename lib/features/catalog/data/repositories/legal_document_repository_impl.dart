import 'package:dartz/dartz.dart';

import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/legal_document.dart';
import '../../domain/entities/paginated_legal_documents.dart';
import '../../domain/repositories/legal_document_repository.dart';
import '../datasources/legal_document_remote_data_source.dart';
import '../models/legal_content_model.dart';
import '../models/paginated_legal_documents_model.dart';

class LegalDocumentRepositoryImpl implements LegalDocumentRepository {
  final LegalDocumentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LegalDocumentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedLegalGroups>> getLegalDocuments({
    required int page,
    required int pageSize,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final PaginatedLegalGroupsModel remoteGroups = await remoteDataSource
            .getLegalDocuments(page: page, pageSize: pageSize);
        return Right(remoteGroups.toEntity());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<LegalContent>>> getLegalDocumentsByCategoryId({
    required String id,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteDocuments = await remoteDataSource
            .getLegalDocumentsByCategoryId(id: id);

        return Right(
          remoteDocuments
              .map((model) => (model as LegalContentModel).toEntity())
              .toList(),
        );
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
