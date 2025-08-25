import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/usecases/usecase_params.dart';
import '../entities/quize.dart';
import '../repositories/quize_repository.dart';

class GetQuizzesByCategoryUsecase
    extends UseCase<List<Quiz>, CategoryPageParams> {
  final QuizRepository repository;

  GetQuizzesByCategoryUsecase(this.repository);

  @override
  Future<Either<Failure, List<Quiz>>> call(CategoryPageParams params) async {
    return await repository.getQuizzesByCategory(
      categoryId: params.categoryId,
      page: params.page,
      limit: params.limit,
    );
  }
}
