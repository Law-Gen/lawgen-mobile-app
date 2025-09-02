import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_legal_documents.dart';
import '../repositories/legal_document_repository.dart';

class GetLegalDocumentsUsecase
    extends UseCase<PaginatedLegalDocuments, GetLegalDocumentsParams> {
  final LegalDocumentRepository repository;

  GetLegalDocumentsUsecase(this.repository);

  @override
  Future<Either<Failure, PaginatedLegalDocuments>> call(
    GetLegalDocumentsParams params,
  ) async {
    return await repository.getLegalDocuments(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetLegalDocumentsParams {
  final int page;
  final int pageSize;

  GetLegalDocumentsParams({required this.page, required this.pageSize});
}
