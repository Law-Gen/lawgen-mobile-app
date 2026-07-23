import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/usecases/usecase_params.dart';
import '../entities/question.dart';
import '../repositories/quize_repository.dart';

class GetQuestionsByQuizIdUsecase extends UseCase<List<Question>, IdParams> {
  final QuizRepository repository;

  GetQuestionsByQuizIdUsecase(this.repository);

  @override
  Future<Either<Failure, List<Question>>> call(IdParams params) async {
    return await repository.getQuestionsByQuizId(params.id);
  }
}
