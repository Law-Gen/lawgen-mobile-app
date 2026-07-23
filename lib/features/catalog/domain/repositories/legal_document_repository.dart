import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/legal_document.dart'; // We can reuse this entity
import '../entities/paginated_legal_documents.dart';

abstract class LegalDocumentRepository {
  /// Fetches the paginated list of content categories/groups
  Future<Either<Failure, PaginatedLegalGroups>> getLegalDocuments({
    required int page,
    required int pageSize,
  });

  /// Fetches the list of documents for a specific category ID
  Future<Either<Failure, List<LegalContent>>> getLegalDocumentsByCategoryId({
    required String id,
  });
}
