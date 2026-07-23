import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/usecases/usecase_params.dart';
import '../entities/quize.dart';
import '../repositories/quize_repository.dart';

class GetQuizByIdUsecase extends UseCase<Quiz, IdParams> {
  final QuizRepository repository;

  GetQuizByIdUsecase(this.repository);

  @override
  Future<Either<Failure, Quiz>> call(IdParams params) async {
    return await repository.getQuizById(params.id);
  }
}
