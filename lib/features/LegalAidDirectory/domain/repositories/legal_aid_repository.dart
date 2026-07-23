import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart'; // Assuming you have this core error file
import '../entities/paginated_legal_entities.dart';

abstract class LegalAidRepository {
  Future<Either<Failure, PaginatedLegalEntities>> getLegalEntities({
    required int page,
    required int pageSize,
  });
}
