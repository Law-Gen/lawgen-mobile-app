import 'package:equatable/equatable.dart';

class LegalDocument extends Equatable {
  final String id;
  final String groupName;
  final String name;
  final String description;
  final String url;
  final String language;

  const LegalDocument({
    required this.id,
    required this.groupName,
    required this.name,
    required this.description,
    required this.url,
    required this.language,
  });

  @override
  List<Object> get props => [id, groupName, name, description, url, language];
}
