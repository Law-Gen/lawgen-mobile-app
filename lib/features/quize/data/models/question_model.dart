import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.text,
    required super.options,
    required super.correctOption,
  });

  // ✅ Convert entity → model
  factory QuestionModel.fromEntity(Question question) {
    return QuestionModel(
      id: question.id,
      text: question.text,
      options: Map<String, String>.from(question.options),
      correctOption: question.correctOption,
    );
  }

  // 🧠 Convert JSON → model
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      options: Map<String, String>.from(json['options'] as Map),
      // 👇 FIXED: Changed from 'correctOption' to match the API response key
      correctOption: json['correct_option'] as String,
    );
  }

  // 🔄 Convert model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      // 👇 FIXED: Changed to 'correct_option' to match the API standard
      'correct_option': correctOption,
    };
  }

  // 🔄 Convert model → entity
  Question toEntity() {
    return Question(
      id: id,
      text: text,
      options: options,
      correctOption: correctOption,
    );
  }
}
