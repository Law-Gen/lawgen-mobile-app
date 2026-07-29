import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:http/http.dart' as http;

import '../../../../core/errors/exception.dart';
import '../../domain/entities/streamed_chat_response.dart';
import '../models/message_model.dart';
import '../models/paginated_chat_sessions_model.dart';
import 'package:http_parser/http_parser.dart';

abstract class ChatRemoteDataSource {
  // MODIFIED: Added optional sessionId
  Stream<StreamedChatResponse> sendQuery({
    required String query,
    required String language,
    String? sessionId,
  });

  Future<PaginatedChatSessionsModel> listUserChatSessions();

  Future<List<MessageModel>> getMessagesFromSession(String sessionId);

  Stream<List<int>> sendVoiceQuery({
    required File audioFile,
    String? sessionId,
    required String language,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'https://lawgen-backend-3ln1.onrender.com';
  final String accessToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjhiOTg4OWZhNzViMGFlMzA3NWZhMDE5Iiwicm9sZSI6ImFkbWluIiwicGxhbiI6ImVudGVycHJpc2UiLCJhZ2UiOjAsImdlbmRlciI6ImZlbWFsZSIsImV4cCI6MTc1NzMzOTQ5NSwiaWF0IjoxNzU3MzIxNDk1fQ.98JX0rHTIX5bnTDK2bkj9giZSKcgtZ0lqiLxnx-2VEc';

  ChatRemoteDataSourceImpl({required this.client});

  @override
  Stream<StreamedChatResponse> sendQuery({
    required String query,
    required String language,
    String? sessionId,
  }) {
    final controller = StreamController<StreamedChatResponse>();
    final url = '$baseUrl/api/v1/chats/query';

    // The body now includes the session ID if available
    final body = {
      "query": query,
      "language": language,
      if (sessionId != null) "session_id": sessionId,
    };

    SSEClient.subscribeToSSE(
      method: SSERequestType.POST,
      url: url,
      header: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: body,
    ).listen(
      (event) {
        if (event.data == null || event.event == null) return;
        try {
          final data = json.decode(event.data!);
          switch (event.event) {
            case 'session_id':
              controller.add(SessionId(data['id']));
              break;
            case 'message':
              controller.add(
                MessageChunk(text: data['text'], sources: data['sources']),
              );
              break;
            case 'complete':
              controller.add(
                StreamComplete(
                  isComplete: data['is_complete'],
                  suggestedQuestions: List<String>.from(
                    data['suggested_questions'],
                  ),
                ),
              );
              break;
          }
        } catch (e) {
          controller.addError(ServerException());
        }
      },
      onError: (error) {
        controller.addError(ServerException());
        controller.close(); // Close stream on error
      },
      onDone: () {
        controller.close(); // Close stream when SSE connection is done
      },
    );

    return controller.stream;
  }

  @override
  Future<PaginatedChatSessionsModel> listUserChatSessions() async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/chats/sessions'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return PaginatedChatSessionsModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MessageModel>> getMessagesFromSession(String sessionId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/chats/sessions/$sessionId/messages'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final messages = json.decode(response.body) as List;
      return messages.map((message) => MessageModel.fromJson(message)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Stream<List<int>> sendVoiceQuery({
    required File audioFile,
    String? sessionId,
    required String language,
  }) async* {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/v1/chats/voice-query'),
    );

    request.headers['Authorization'] = 'Bearer $accessToken';

    if (sessionId != null) {
      request.fields['sessionId'] = sessionId;
    }
    request.fields['language'] = language;

    // Add the file with its specific Content-Type.
    // This now works because of the import added at the top of the file.

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
        contentType: MediaType('audio', 'mpeg'),
      ),
    );

    print("[DataSource] Sending voice query to ${request.url}");
    print("[DataSource] with file: ${audioFile.path}");
    print("[DataSource] with Content-Type: audio/mpeg");

    final response = await client.send(request);

    print(
      "[DataSource] Voice query response status code: ${response.statusCode}",
    );

    if (response.statusCode == 200) {
      yield* response.stream;
    } else {
      final responseBody = await http.Response.fromStream(response);
      print("[DataSource] SERVER ERROR BODY: ${responseBody.body}");
      throw ServerException();
    }
  }
}
