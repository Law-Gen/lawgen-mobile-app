import 'package:equatable/equatable.dart';

/// Quiz Entity (basic quiz info under a category)
class Quiz extends Equatable {
  final String id;
  final String name;
  final String description;

  const Quiz({required this.id, required this.name, required this.description});

  @override
  List<Object> get props => [id];
}
