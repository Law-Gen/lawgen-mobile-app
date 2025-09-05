// import '';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/faliures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failures, List<Message>>> getChatMessages(
    String conversationId,
  );

  /// Streams incremental AI response messages for a given question and language.
  /// Emits one `Message` per chunk/partial update. Errors should be returned
  /// as a `Left(Failures)` event (or via stream error for terminal failures).
  Stream<Either<Failures, String>> aiResponseStream();


  // ask question 
  Future <Either<Failures,void>> askQuestion(
    String question,
    String language,
  );

  //ask follow app question
   Future <Either<Failures,void>> askFollowUpQuestion(
    String converstaionID,
    String question,
    String language,
  );
  // if i want to stop the stream
  Future<void> stopAskQuestionStream();
  // let the user
  Future<Either<Failures, List<Conversation>>> getChatHistory();

}
