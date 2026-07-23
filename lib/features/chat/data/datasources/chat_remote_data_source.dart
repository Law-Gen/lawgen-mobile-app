import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../../core/errors/exception.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getChatHistory();
  Future<List<MessageModel>> getChatMessages(String conversationId);
}

// Renamed URIs to avoid name collision with class methods
final chatHistoryUri = Uri.parse('https://g5-flutter-learning-path-be-tvum.onrender.com/api/v2/auth/register');
final chatMessagesUri = Uri.parse('https://g5-flutter-learning-path-be-tvum.onrender.com/api/v2/auth/login');

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  ChatRemoteDataSourceImpl({required this.client, required this.secureStorage});

  String _maskToken(String? token) {
    if (token == null) return 'null';
    final show = min(6, token.length);
    return '${token.substring(0, show)}... (${token.length} chars)';
  }

  @override
  Future<List<ConversationModel>> getChatHistory() async {
    final authToken = await secureStorage.read(key: 'AUTH_TOKEN');
    print('getChatHistory: retrieved authToken=${_maskToken(authToken)}');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authToken ?? "null"}',
    };
    print('getChatHistory: GET $chatHistoryUri');
    print('getChatHistory: headers=${headers..update('Authorization', (v) => 'Bearer ${_maskToken(authToken)}')}');

    final response = await client.get(chatHistoryUri, headers: headers);
    print('getChatHistory: response.statusCode=${response.statusCode}');
    print('getChatHistory: response.body=${response.body}');

    if (response.statusCode == 200) {
      try {
        final body = json.decode(response.body) as List<dynamic>;
        print('getChatHistory: parsed body length=${body.length}');
        // TODO: parse JSON into ConversationModel instances once a parsing constructor exists on the model
        return <ConversationModel>[];
      } catch (e, st) {
        print('getChatHistory: JSON parse error: $e\n$st');
        throw ServerException();
      }
    } else {
      print('getChatHistory: server error ${response.statusCode}');
      throw ServerException();
    }
  }

  @override
  Future<List<MessageModel>> getChatMessages(String conversationId) async {
    final authToken = await secureStorage.read(key: 'AUTH_TOKEN');
    print('getChatMessages: conversationId=$conversationId authToken=${_maskToken(authToken)}');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authToken ?? "null"}',
    };
    print('getChatMessages: GET $chatMessagesUri');
    print('getChatMessages: headers=${headers..update('Authorization', (v) => 'Bearer ${_maskToken(authToken)}')}');

    final response = await client.get(chatMessagesUri, headers: headers);
    print('getChatMessages: response.statusCode=${response.statusCode}');
    print('getChatMessages: response.body=${response.body}');

    if (response.statusCode == 200) {
      try {
        final body = json.decode(response.body) as List<dynamic>;
        print('getChatMessages: parsed body length=${body.length}');
        // TODO: parse JSON into MessageModel instances once a parsing constructor exists on the model
        return <MessageModel>[];
      } catch (e, st) {
        print('getChatMessages: JSON parse error: $e\n$st');
        throw ServerException();
      }
    } else {
      print('getChatMessages: server error ${response.statusCode}');
      throw ServerException();
    }
  }
}