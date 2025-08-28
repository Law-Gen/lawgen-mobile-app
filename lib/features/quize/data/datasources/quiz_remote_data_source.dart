// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../../../core/errors/exception.dart';
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

// // ✅ API endpoints
// const String _baseUrl = 'https://your-api.com/api/v1';
// const String CACHED_AUTH_TOKEN = 'CACHED_AUTH_TOKEN';

// class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
//   final http.Client client;

//   QuizRemoteDataSourceImpl({required this.client});

//   // ✅ Get headers with token if available
//   Future<Map<String, String>> get _headers async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(CACHED_AUTH_TOKEN);

//     final headers = {'Content-Type': 'application/json'};
//     if (token != null && token.isNotEmpty) {
//       headers['Authorization'] = 'Bearer $token';
//     }
//     return headers;
//   }

//   // ✅ Unified GET handler
//   Future<http.Response> _getRequest(Uri url) async {
//     final response = await client.get(url, headers: await _headers);
//     if (response.statusCode == 200) {
//       return response;
//     } else {
//       throw ServerException();
//     }
//   }

//   @override
//   Future<List<QuizCategoryModel>> getQuizCategories({
//     required int page,
//     required int limit,
//   }) async {
//     final url = Uri.parse('$_baseUrl/quiz-categories?page=$page&limit=$limit');
//     final response = await _getRequest(url);

//     final decoded = json.decode(response.body) as Map<String, dynamic>;
//     final items = decoded['items'] as List<dynamic>;

//     return items.map((json) => QuizCategoryModel.fromJson(json)).toList();
//   }

//   @override
//   Future<List<QuizModel>> getQuizzesByCategory({
//     required String categoryId,
//     required int page,
//     required int limit,
//   }) async {
//     final url = Uri.parse(
//       '$_baseUrl/quiz-categories/$categoryId/quizzes?page=$page&limit=$limit',
//     );
//     final response = await _getRequest(url);

//     final decoded = json.decode(response.body) as Map<String, dynamic>;
//     final items = decoded['items'] as List<dynamic>;

//     return items.map((json) => QuizModel.fromJson(json)).toList();
//   }

//   @override
//   Future<QuizModel> getQuizById(String quizId) async {
//     final url = Uri.parse('$_baseUrl/quizzes/$quizId');
//     final response = await _getRequest(url);

//     final decoded = json.decode(response.body) as Map<String, dynamic>;
//     final quizJson = decoded; // API returns quiz with questions included

//     return QuizModel.fromJson(quizJson);
//   }

//   @override
//   Future<List<QuestionModel>> getQuestionsByQuizId(String quizId) async {
//     final url = Uri.parse('$_baseUrl/quizzes/$quizId');
//     final response = await _getRequest(url);

//     final decoded = json.decode(response.body) as Map<String, dynamic>;
//     final questionsJson = decoded['questions'] as List<dynamic>;

//     return questionsJson.map((json) => QuestionModel.fromJson(json)).toList();
//   }
// }

import '../models/question_model.dart';
import '../models/quiz_category_model.dart';
import '../models/quiz_model.dart';

abstract class QuizRemoteDataSource {
  Future<List<QuizCategoryModel>> getQuizCategories({
    required int page,
    required int limit,
  });
  Future<List<QuizModel>> getQuizzesByCategory({
    required String categoryId,
    required int page,
    required int limit,
  });
  Future<QuizModel> getQuizById(String quizId);
  Future<List<QuestionModel>> getQuestionsByQuizId(String quizId);
}

/// ✅ Dummy implementation instead of real API calls
class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  QuizRemoteDataSourceImpl();

  @override
  Future<List<QuizCategoryModel>> getQuizCategories({
    required int page,
    required int limit,
  }) async {
    // ✅ Return hardcoded dummy data
    await Future.delayed(const Duration(milliseconds: 300)); // simulate delay
    return [
      const QuizCategoryModel(id: 'cat_1', name: 'Level 1'),
      const QuizCategoryModel(id: 'cat_2', name: 'Level 2'),
    ];
  }

  @override
  Future<List<QuizModel>> getQuizzesByCategory({
    required String categoryId,
    required int page,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const QuizModel(
        id: 'quiz_id_1',
        name: 'Inheritance Law Basics',
        description: 'Test your knowledge of Ethiopian inheritance laws.',
        questions: [], // questions will be fetched separately
      ),
      const QuizModel(
        id: 'quiz_id_2',
        name: 'Contract Law',
        description: 'Basics of contract law.',
        questions: [],
      ),
    ];
  }

  @override
  Future<QuizModel> getQuizById(String quizId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const QuizModel(
      id: 'quiz_id_1',
      name: 'Inheritance Law Basics',
      description: 'Learn about inheritance rules.',
      questions: [
        QuestionModel(
          id: 'q1',
          text: 'Who inherits property if there is no will?',
          options: {
            'A': 'Spouse only',
            'B': 'Children equally',
            'C': 'State',
            'D': 'Eldest son',
          },
          correctOption: 'B',
        ),
        QuestionModel(
          id: 'q2',
          text: 'Can property be inherited without a legal document?',
          options: {'A': 'Yes', 'B': 'No'},
          correctOption: 'A',
        ),
      ],
    );
  }

  @override
  Future<List<QuestionModel>> getQuestionsByQuizId(String quizId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const QuestionModel(
        id: 'q1',
        text: 'Who inherits property if there is no will?',
        options: {
          'A': 'Spouse only',
          'B': 'Children equally',
          'C': 'State',
          'D': 'Eldest son',
        },
        correctOption: 'B',
      ),
      const QuestionModel(
        id: 'q2',
        text: 'Can property be inherited without a legal document?',
        options: {'A': 'Yes', 'B': 'No'},
        correctOption: 'A',
      ),
    ];
  }
}
