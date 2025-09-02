import 'package:equatable/equatable.dart';
import 'question.dart';

/// Quiz Entity
class Quiz extends Equatable {
  final String id;
  final String name;
  final String description;
  final String totalQuestion;
  final List<Question> questions;

  const Quiz({
    required this.id,
    required this.name,
    required this.description,
    required this.totalQuestion,
    this.questions = const [],
  });

  @override
  List<Object> get props => [id, name, description, totalQuestion, questions];
}
