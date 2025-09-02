import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/usecases/usecase_params.dart';
import '../entities/quiz_category.dart';
import '../repositories/quize_repository.dart';

class GetQuizCategoriesUsecase extends UseCase<List<QuizCategory>, PageParams> {
  final QuizRepository repository;

  GetQuizCategoriesUsecase(this.repository);

  @override
  Future<Either<Failure, List<QuizCategory>>> call(PageParams params) async {
    return await repository.getQuizCategories(
      page: params.page,
      limit: params.limit,
    );
  }
}
