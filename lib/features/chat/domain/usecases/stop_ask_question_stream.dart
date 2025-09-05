import '../repository/chat_repository.dart';

class StopAskQuestionStreamUseCase {
  final ChatRepository repository;
  StopAskQuestionStreamUseCase(this.repository);

  Future<void> call() => repository.stopAskQuestionStream();
}
