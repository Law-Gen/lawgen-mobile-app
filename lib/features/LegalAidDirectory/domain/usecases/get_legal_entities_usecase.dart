import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart'; // Assuming a generic use case structure
import '../entities/paginated_legal_entities.dart';
import '../repositories/legal_aid_repository.dart';

class GetLegalEntitiesUsecase
    extends UseCase<PaginatedLegalEntities, GetLegalEntitiesParams> {
  final LegalAidRepository repository;

  GetLegalEntitiesUsecase(this.repository);

  @override
  Future<Either<Failure, PaginatedLegalEntities>> call(
    GetLegalEntitiesParams params,
  ) async {
    return await repository.getLegalEntities(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetLegalEntitiesParams extends Equatable {
  final int page;
  final int pageSize;

  const GetLegalEntitiesParams({required this.page, required this.pageSize});

  @override
  List<Object> get props => [page, pageSize];
}
