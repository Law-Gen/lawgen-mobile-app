import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repository/chat_repository.dart';

class SendVoiceQuery {
  final ChatRepository repository;

  SendVoiceQuery(this.repository);

  Future<Either<Failures, Stream<List<int>>>> call({
    required File audioFile,
    String? sessionId,
    required String language,
  }) async {
    return await repository.sendVoiceQuery(
      audioFile: audioFile,
      sessionId: sessionId,
      language: language,
    );
  }
}
