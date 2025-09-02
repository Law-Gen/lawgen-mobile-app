import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/paginated_legal_documents.dart';

abstract class LegalDocumentRepository {
  Future<Either<Failure, PaginatedLegalDocuments>> getLegalDocuments({
    required int page,
    required int pageSize,
  });
}
