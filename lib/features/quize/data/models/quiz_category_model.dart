import '../../domain/entities/quiz_category.dart';

class QuizCategoryModel extends QuizCategory {
  const QuizCategoryModel({required super.id, required super.name});

  // ✅ Convert entity → model
  factory QuizCategoryModel.fromEntity(QuizCategory category) {
    return QuizCategoryModel(id: category.id, name: category.name);
  }

  // 🧠 Convert JSON → model
  factory QuizCategoryModel.fromJson(Map<String, dynamic> json) {
    return QuizCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  // 🔄 Convert model → JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  // 🔄 Convert model → entity
  QuizCategory toEntity() {
    return QuizCategory(id: id, name: name);
  }
}
