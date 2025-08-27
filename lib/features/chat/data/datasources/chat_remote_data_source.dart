import 'dart:convert';

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
  // token form secure storage
  //FLUTTER SECURE STORAGE
  final FlutterSecureStorage secureStorage;

  ChatRemoteDataSourceImpl({required this.client, required this.secureStorage});


  @override
  Future<List<ConversationModel>> getChatHistory() async{
    // Get the auth token from secure storage
    final authToken = await secureStorage.read(key: 'AUTH_TOKEN');

    // Make the API call to get chat history
    final response = await client.get(
      chatHistoryUri,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      // TODO: parse JSON into ConversationModel instances once a parsing constructor exists on the model
      final body = json.decode(response.body) as List<dynamic>;
      return <ConversationModel>[];
    } else {
      throw ServerException('Failed to load chat history');
    }
  }

  @override
  Future<List<MessageModel>> getChatMessages(String conversationId) async {
    // Get the auth token from secure storage
    final authToken = await secureStorage.read(key: 'AUTH_TOKEN');

    // Make the API call to get chat messages for the given conversationId
    final response = await client.get(
      chatMessagesUri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      // TODO: parse JSON into MessageModel instances once a parsing constructor exists on the model
      final body = json.decode(response.body) as List<dynamic>;
      return <MessageModel>[];
    } else {
      throw ServerException('Failed to load chat messages');
    }
  }
}

  