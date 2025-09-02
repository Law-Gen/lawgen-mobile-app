import '../../domain/entities/legal_document.dart';

class LegalDocumentModel extends LegalDocument {
  const LegalDocumentModel({
    required super.id,
    required super.groupName,
    required super.name,
    required super.description,
    required super.url,
    required super.language,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      id: json['id'] as String,
      groupName: json['group_name'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      language: json['language'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_name': groupName,
      'name': name,
      'description': description,
      'url': url,
      'language': language,
    };
  }

  LegalDocument toEntity() {
    return LegalDocument(
      id: id,
      groupName: groupName,
      name: name,
      description: description,
      url: url,
      language: language,
    );
  }
}
