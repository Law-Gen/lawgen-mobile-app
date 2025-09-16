import '../../domain/entities/source.dart';

class SourceModel extends Source {
  const SourceModel({
    required String content,
    required String source,
    required String articleNumber,
    required List<String> topics,
  }) : super(
         content: content,
         source: source,
         articleNumber: articleNumber,
         topics: topics,
       );
  factory SourceModel.fromJson(Map<String, dynamic> json) {
    return SourceModel(
      content: json['content'],
      source: json['source'],
      articleNumber: json['article_number'],
      topics: List<String>.from(json['topics']),
    );
  }
}
