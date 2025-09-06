// lib/domain/usecases/get_quiz_categories_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/usecases/usecase_params.dart';
import '../entities/paginated_response.dart';
import '../entities/quiz_category.dart';
import '../repositories/quize_repository.dart'; // Note: Renamed from quize_repository.dart

// 👇 CHANGED: The success type is now a PaginatedResponse, not a List.
class GetQuizCategoriesUsecase
    extends UseCase<PaginatedResponse<QuizCategory>, PageParams> {
  final QuizRepository repository;

  GetQuizCategoriesUsecase(this.repository);

  @override
  // 👇 CHANGED: The return signature now matches the repository's contract.
  Future<Either<Failure, PaginatedResponse<QuizCategory>>> call(
    PageParams params,
  ) async {
    // This line now works because the types match perfectly.
    return await repository.getQuizCategories(
      page: params.page,
      limit: params.limit,
    );
  }
}
