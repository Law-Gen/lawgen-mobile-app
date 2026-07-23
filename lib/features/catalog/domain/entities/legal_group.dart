import 'package:equatable/equatable.dart';

class LegalGroup extends Equatable {
  final String id;
  final String groupName;

  const LegalGroup({required this.id, required this.groupName});

  @override
  List<Object> get props => [id, groupName];
}
