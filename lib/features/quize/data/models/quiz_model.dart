import '../../domain/entities/quize.dart';
import 'question_model.dart'; // ✅ You’ll need this for QuestionModel

class QuizModel extends Quiz {
  const QuizModel({
    required super.id,
    required super.name,
    required super.description,
    super.questions = const [],
  });

  // ✅ Convert entity → model
  factory QuizModel.fromEntity(Quiz quiz) {
    return QuizModel(
      id: quiz.id,
      name: quiz.name,
      description: quiz.description,
      questions: quiz.questions, // already a List<Question>
    );
  }

  // 🧠 Convert JSON → model
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // 🔄 Convert model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
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
      name: name,
      description: description,
      questions: questions,
    );
  }
}
