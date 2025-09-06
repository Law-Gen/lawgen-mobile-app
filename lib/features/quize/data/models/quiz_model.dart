// lib/data/models/quiz_model.dart

import '../../domain/entities/quize.dart';
import 'question_model.dart';

class QuizModel extends Quiz {
  const QuizModel({
    required super.id,
    // 👇 ADDED: Added categoryId to match the entity and API response
    required super.categoryId,
    required super.name,
    required super.description,
    required super.totalQuestion,
    super.questions = const [],
  });

  // ✅ Convert entity → model
  factory QuizModel.fromEntity(Quiz quiz) {
    return QuizModel(
      id: quiz.id,
      categoryId: quiz.categoryId, // ADDED
      name: quiz.name,
      description: quiz.description,
      totalQuestion: quiz.totalQuestion,
      questions: quiz.questions,
    );
  }

  // 🧠 Convert JSON → model
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final questions =
        (json['questions'] as List<dynamic>?)
            ?.map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
            .toList() ??
        [];

    final totalQ = json['total_questions'] != null
        ? json['total_questions'].toString()
        : questions.isNotEmpty
        ? questions.length.toString()
        : '0';

    return QuizModel(
      id: json['id'] as String,
      // 👇 ADDED: Parsed the 'category_id' from the JSON
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      totalQuestion: totalQ,
      questions: questions,
    );
  }

  // 🔄 Convert model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId, // ADDED
      'name': name,
      'description': description,
      'total_questions': totalQuestion,
      'questions': questions
          .map(
            (q) => (q is QuestionModel)
                ? q.toJson()
                : QuestionModel.fromEntity(q).toJson(),
          )
          .toList(),
    };
  }

  // 🔄 Convert model → entity
  Quiz toEntity() {
    return Quiz(
      id: id,
      categoryId: categoryId, // ADDED
      name: name,
      description: description,
      totalQuestion: totalQuestion,
      // Ensure questions are also converted to entities
      questions: questions.map((q) => (q as QuestionModel).toEntity()).toList(),
    );
  }
}
