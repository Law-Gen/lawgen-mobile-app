import 'package:equatable/equatable.dart';
import 'question.dart';

class Quiz extends Equatable {
  final String id;
  final String categoryId; // ✅ ADDED: This is essential data from the API
  final String name;
  final String description;
  final String totalQuestion;
  final List<Question> questions;

  const Quiz({
    required this.id,
    required this.categoryId, // ✅ ADDED
    required this.name,
    required this.description,
    required this.totalQuestion,
    this.questions = const [],
  });

  @override
  // ✅ ADDED: Add categoryId to props for value equality
  List<Object> get props => [
    id,
    categoryId,
    name,
    description,
    totalQuestion,
    questions,
  ];
}
