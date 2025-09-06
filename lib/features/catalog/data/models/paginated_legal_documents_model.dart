import '../../domain/entities/paginated_legal_documents.dart';
import 'legal_group_model.dart';

class PaginatedLegalGroupsModel extends PaginatedLegalGroups {
  const PaginatedLegalGroupsModel({
    required super.items,
    required super.totalItems,
    required super.totalPages,
    required super.currentPage,
    required super.pageSize,
  });

  factory PaginatedLegalGroupsModel.fromJson(Map<String, dynamic> json) {
    return PaginatedLegalGroupsModel(
      items: (json['items'] as List)
          .map((item) => LegalGroupModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalItems: json['total_items'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
      pageSize: json['page_size'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': (items as List<LegalGroupModel>)
          .map((item) => item.toJson())
          .toList(),
      'total_items': totalItems,
      'total_pages': totalPages,
      'current_page': currentPage,
      'page_size': pageSize,
    };
  }

  PaginatedLegalGroups toEntity() {
    return PaginatedLegalGroups(
      items: items.map((item) => (item as LegalGroupModel).toEntity()).toList(),
      totalItems: totalItems,
      totalPages: totalPages,
      currentPage: currentPage,
      pageSize: pageSize,
    );
  }
}
