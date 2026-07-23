import 'package:dartz/dartz.dart';
import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart'; // Assuming you have this
import '../../domain/entities/paginated_legal_entities.dart';
import '../../domain/repositories/legal_aid_repository.dart';
import '../datasources/legal_aid_remote_data_source.dart';

class LegalAidRepositoryImpl implements LegalAidRepository {
  final LegalAidRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LegalAidRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedLegalEntities>> getLegalEntities({
    required int page,
    required int pageSize,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getLegalEntities(
          page: page,
          pageSize: pageSize,
        );
        return Right(remoteData.toEntity());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
