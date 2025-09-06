
import '../../domain/entities/legal_group.dart';

class LegalGroupModel extends LegalGroup {
  const LegalGroupModel({required super.id, required super.groupName});

  factory LegalGroupModel.fromJson(Map<String, dynamic> json) {
    return LegalGroupModel(
      id: json['group_id'] as String,
      groupName: json['group_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'group_id': id, 'group_name': groupName};
  }

  LegalGroup toEntity() {
    return LegalGroup(id: id, groupName: groupName);
  }
}
