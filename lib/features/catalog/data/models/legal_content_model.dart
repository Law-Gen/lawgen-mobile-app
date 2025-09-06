// lib/data/models/legal_content_model.dart

import '../../domain/entities/legal_document.dart';

class LegalContentModel extends LegalContent {
  const LegalContentModel({
    required super.id,
    required super.groupId,
    required super.groupName,
    required super.name,
    required super.description,
    required super.url,
    required super.language,
  });

  factory LegalContentModel.fromJson(Map<String, dynamic> json) {
    return LegalContentModel(
      id: json['id'] as String,
      // CHANGED: 'group_id' is now 'GroupID' to match the API response
      groupId: json['GroupID'] as String,
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
      // It's good practice to also align the key here for consistency
      'GroupID': groupId,
      'group_name': groupName,
      'name': name,
      'description': description,
      'url': url,
      'language': language,
    };
  }

  LegalContent toEntity() {
    return LegalContent(
      id: id,
      groupId: groupId,
      groupName: groupName,
      name: name,
      description: description,
      url: url,
      language: language,
    );
  }
}
