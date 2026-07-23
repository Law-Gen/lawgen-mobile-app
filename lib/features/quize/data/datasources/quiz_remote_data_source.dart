import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// I'm assuming your exception class is in this path.
// Adjust the path if your ServerException class is located elsewhere.
import '../../../../core/errors/exception.dart';
import '../../domain/entities/paginated_response.dart';
import '../models/paginated_response_model.dart';
import '../models/question_model.dart';
import '../models/quiz_category_model.dart';
import '../models/quiz_model.dart';

/// Abstract contract for the remote data source for quizzes.
abstract class QuizRemoteDataSource {
  /// Fetches a paginated list of all quiz categories.
  Future<PaginatedResponse<QuizCategoryModel>> getQuizCategories({
    required int page,
    required int limit,
  });

  /// Fetches a paginated list of quizzes for a specific category.
  Future<PaginatedResponse<QuizModel>> getQuizzesByCategory({
    required String categoryId,
    required int page,
    required int limit,
  });

  /// Fetches a single quiz by its unique ID.
  Future<QuizModel> getQuizById(String quizId);

  /// Fetches a list of all questions for a specific quiz.
  Future<List<QuestionModel>> getQuestionsByQuizId(String quizId);
}

// --- Implementation ---

const String _baseUrl = 'https://lawgen-backend-3ln1.onrender.com/api/v1';
const String SECURE_AUTH_TOKEN_KEY = 'SECURE_AUTH_TOKEN_KEY'; // Example key

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage storage;

  QuizRemoteDataSourceImpl({required this.client, required this.storage});

  /// A private getter to construct request headers, including the auth token.
  Future<Map<String, String>> get _headers async {
    // final token = await storage.read(key: SECURE_AUTH_TOKEN_KEY);
    final token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjhiOTg4OWZhNzViMGFlMzA3NWZhMDE5Iiwicm9sZSI6ImFkbWluIiwicGxhbiI6ImVudGVycHJpc2UiLCJhZ2UiOjI1LCJnZW5kZXIiOiJtYWxlIiwiZXhwIjoxNzU3MTgzODA3LCJpYXQiOjE3NTcxNjU4MDd9.3EpiHFIAdm1MQtYOTd1uy6weZh1PYnB2g8v31gC-E5w';
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// A unified handler for making GET requests and handling non-200 responses.
  Future<http.Response> _getRequest(Uri url) async {
    final response = await client.get(url, headers: await _headers);
    if (response.statusCode == 200) {
      return response;
    } else {
      // You can add more specific error handling here based on status codes
      // e.g., 401 for Unauthorized, 404 for Not Found, etc.

      // ✅ THIS IS THE CRITICAL PART FOR DEBUGGING
      // Print the error details before throwing the exception.
      debugPrint('🔴 API ERROR');
      debugPrint('➡️ URL: $url');
      debugPrint('📡 Status Code: ${response.statusCode}');
      debugPrint('📩 Response Body: ${response.body}');
      debugPrint('------------------------------');

      throw ServerException();
    }
  }

  @override
  Future<PaginatedResponse<QuizCategoryModel>> getQuizCategories({
    required int page,
    required int limit,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/quizzes/categories?page=$page&limit=$limit',
    );
    final response = await _getRequest(url);
    final decoded = json.decode(response.body) as Map<String, dynamic>;

    // Use the PaginatedResponseModel to parse the full response
    return PaginatedResponseModel.fromJson(decoded, (itemJson) {
      return QuizCategoryModel.fromJson(itemJson as Map<String, dynamic>);
    });
  }

  @override
  Future<PaginatedResponse<QuizModel>> getQuizzesByCategory({
    required String categoryId,
    required int page,
    required int limit,
  }) async {
    // NOTE: This endpoint assumes that the API returns a paginated list of quizzes.
    // Based on your provided spec, the API returns categories here, which might be an error in the spec.
    // This code correctly handles a response of paginated QUIZZES.
    final url = Uri.parse(
      '$_baseUrl/quizzes/categories/$categoryId?page=$page&limit=$limit',
    );
    final response = await _getRequest(url);
    final decoded = json.decode(response.body) as Map<String, dynamic>;

    return PaginatedResponseModel.fromJson(decoded, (itemJson) {
      return QuizModel.fromJson(itemJson as Map<String, dynamic>);
    });
  }

  @override
  Future<QuizModel> getQuizById(String quizId) async {
    final url = Uri.parse('$_baseUrl/quizzes/$quizId');
    final response = await _getRequest(url);
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return QuizModel.fromJson(decoded);
  }

  @override
  Future<List<QuestionModel>> getQuestionsByQuizId(String quizId) async {
    final url = Uri.parse('$_baseUrl/quizzes/$quizId/questions');
    final response = await _getRequest(url);

    // This endpoint returns a direct JSON array (a list), not an object.
    final decodedList = json.decode(response.body) as List<dynamic>;

    return decodedList
        .map(
          (jsonItem) =>
              QuestionModel.fromJson(jsonItem as Map<String, dynamic>),
        )
        .toList();
  }
}

// import '../models/question_model.dart';
// import '../models/quiz_category_model.dart';
// import '../models/quiz_model.dart';

// abstract class QuizRemoteDataSource {
//   Future<List<QuizCategoryModel>> getQuizCategories({
//     required int page,
//     required int limit,
//   });
//   Future<List<QuizModel>> getQuizzesByCategory({
//     required String categoryId,
//     required int page,
//     required int limit,
//   });
//   Future<QuizModel> getQuizById(String quizId);
//   Future<List<QuestionModel>> getQuestionsByQuizId(String quizId);
// }

// /// ✅ Dummy implementation instead of real API calls
// class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
//   QuizRemoteDataSourceImpl();

//   @override
//   Future<List<QuizCategoryModel>> getQuizCategories({
//     required int page,
//     required int limit,
//   }) async {
//     // ✅ Return hardcoded dummy data
//     await Future.delayed(const Duration(milliseconds: 300)); // simulate delay
//     return [
//       const QuizCategoryModel(id: 'cat_1', name: 'Level 1'),
//       const QuizCategoryModel(id: 'cat_2', name: 'Level 2'),
//     ];
//   }

//   @override
//   Future<List<QuizModel>> getQuizzesByCategory({
//     required String categoryId,
//     required int page,
//     required int limit,
//   }) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     return [
//       const QuizModel(
//         id: 'quiz_id_1',
//         name: 'Inheritance Law Basics',
//         description: 'Test your knowledge of Ethiopian inheritance laws.',
//         totalQuestion: '2',
//         questions: [], // questions will be fetched separately
//       ),
//       const QuizModel(
//         id: 'quiz_id_2',
//         name: 'Contract Law',
//         description: 'Basics of contract law.',
//         totalQuestion: '2',
//         questions: [],
//       ),
//     ];
//   }

//   @override
//   Future<QuizModel> getQuizById(String quizId) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     return const QuizModel(
//       id: 'quiz_id_1',
//       name: 'Inheritance Law Basics',
//       description: 'Learn about inheritance rules.',
//       totalQuestion: '2',
//       questions: [
//         QuestionModel(
//           id: 'q1',
//           text: 'Who inherits property if there is no will?',
//           options: {
//             'A': 'Spouse only',
//             'B': 'Children equally',
//             'C': 'State',
//             'D': 'Eldest son',
//           },
//           correctOption: 'B',
//         ),
//         QuestionModel(
//           id: 'q2',
//           text: 'Can property be inherited without a legal document?',
//           options: {'A': 'Yes', 'B': 'No'},
//           correctOption: 'A',
//         ),
//       ],
//     );
//   }

//   @override
//   Future<List<QuestionModel>> getQuestionsByQuizId(String quizId) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     return [
//       const QuestionModel(
//         id: 'q1',
//         text: 'Who inherits property if there is no will?',
//         options: {
//           'A': 'Spouse only',
//           'B': 'Children equally',
//           'C': 'State',
//           'D': 'Eldest son',
//         },
//         correctOption: 'B',
//       ),
//       const QuestionModel(
//         id: 'q2',
//         text: 'Can property be inherited without a legal document?',
//         options: {'A': 'Yes', 'B': 'No'},
//         correctOption: 'A',
//       ),
//     ];
//   }
// }
