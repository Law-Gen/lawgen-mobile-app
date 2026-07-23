import 'package:equatable/equatable.dart';

class LegalContent extends Equatable {
  final String id;
  final String groupId;
  final String groupName;
  final String name;
  final String description;
  final String url;
  final String language;

  const LegalContent({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.name,
    required this.description,
    required this.url,
    required this.language,
  });

  @override
  List<Object> get props => [
    id,
    groupId,
    groupName,
    name,
    description,
    url,
    language,
  ];
}
