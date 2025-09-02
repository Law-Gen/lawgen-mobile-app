import 'package:equatable/equatable.dart';

class QuizCategory extends Equatable {
  final String id;
  final String name;

  const QuizCategory({required this.id, required this.name});

  @override
  List<Object> get props => [id];
}
