import 'package:equatable/equatable.dart';

class Source extends Equatable {
  final String content;
  final String source;
  final String articleNumber;
  final List<String> topics;

  const Source({
    required this.content,
    required this.source,
    required this.articleNumber,
    required this.topics,
  });

  @override
  List<Object?> get props => [content, source, articleNumber, topics];
}
