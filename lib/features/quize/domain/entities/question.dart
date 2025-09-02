import 'package:equatable/equatable.dart';

/// Question Entity (for a quiz)
class Question extends Equatable {
  final String id;
  final String text;
  final Map<String, String> options; // e.g., {"A": "Option 1", "B": "Option 2"}
  final String correctOption;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOption,
  });

  @override
  List<Object> get props => [id];
}
