import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/legal_document.dart';
import '../repositories/legal_document_repository.dart';

class GetLegalDocumentsByCategoryIdUsecase
    extends UseCase<List<LegalContent>, GetLegalDocumentsByCategoryIdParams> {
  final LegalDocumentRepository repository;

  GetLegalDocumentsByCategoryIdUsecase(this.repository);

  @override
  Future<Either<Failure, List<LegalContent>>> call(
    GetLegalDocumentsByCategoryIdParams params,
  ) async {
    return await repository.getLegalDocumentsByCategoryId(id: params.id);
  }
}

class GetLegalDocumentsByCategoryIdParams {
  final String id;

  GetLegalDocumentsByCategoryIdParams({required this.id});
}
