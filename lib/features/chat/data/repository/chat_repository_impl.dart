import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network/network_info.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/paginated_chat_sessions.dart';
import '../../domain/entities/streamed_chat_response.dart';
import '../../domain/repository/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  @override
  // MODIFIED: Added optional sessionId and pass it to the remote data source
  Future<Either<Failures, Stream<StreamedChatResponse>>> sendQuery({
    required String query,
    required String language,
    String? sessionId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      final stream = remoteDataSource.sendQuery(
        query: query,
        language: language,
        sessionId: sessionId,
      );
      return Right(stream);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failures, PaginatedChatSessions>> listUserChatSessions() async {
    try {
      final paginatedChatSessions = await remoteDataSource
          .listUserChatSessions();
      return Right(paginatedChatSessions);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failures, List<Message>>> getMessagesFromSession(
    String sessionId,
  ) async {
    try {
      final messages = await remoteDataSource.getMessagesFromSession(sessionId);
      return Right(messages);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failures, Stream<List<int>>>> sendVoiceQuery({
    required File audioFile,
    String? sessionId,
    required String language,
  }) async {
    try {
      final stream = remoteDataSource.sendVoiceQuery(
        audioFile: audioFile,
        sessionId: sessionId,
        language: language,
      );
      return Right(stream);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
