// lib/domain/usecases/get_quizzes_by_category_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/usecases/usecase_params.dart';
import '../entities/paginated_response.dart';
import '../entities/quize.dart';
import '../repositories/quize_repository.dart'; // Note: Renamed from quize_repository.dart

// 👇 CHANGED: The success type is now a PaginatedResponse, not a List.
class GetQuizzesByCategoryUsecase
    extends UseCase<PaginatedResponse<Quiz>, CategoryPageParams> {
  final QuizRepository repository;

  GetQuizzesByCategoryUsecase(this.repository);

  @override
  // 👇 CHANGED: The return signature now matches the repository's contract.
  Future<Either<Failure, PaginatedResponse<Quiz>>> call(
    CategoryPageParams params,
  ) async {
    // This line now works because the types match perfectly.
    return await repository.getQuizzesByCategory(
      categoryId: params.categoryId,
      page: params.page,
      limit: params.limit,
    );
  }
}
