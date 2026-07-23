// import '';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/faliures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../entities/ask_result.dart';

abstract class ChatRepository {
  Future<Either<Failures, List<Message>>> getChatMessages(
    String conversationId,
  );
  // ... existing methods (getChatHistory, getChatMessages) ...

  /// Starts a new conversation by sending a question.
  /// Returns the conversationId and a stream of AI response chunks.
  Future<Either<Failures, AskResult>> askQuestion({
    required String question,
    required String language,
  });

  /// Asks a follow-up question in an existing conversation.
  /// Persists the user's follow-up message locally.
  /// Returns a stream of AI response chunks on success.
  Future<Either<Failures, AskResult>> askFollowUpQuestion({
    required String conversationId,
    required String question,
    required String language,
  });

  /// Saves the final AI message to an existing conversation.
  Future<Either<Failures, void>> saveAiMessage({
    required String conversationId,
    required String content,
  });

  Future<void> stopAskQuestionStream();

  // let the user
  Future<Either<Failures, List<Conversation>>> getChatHistory();
}
