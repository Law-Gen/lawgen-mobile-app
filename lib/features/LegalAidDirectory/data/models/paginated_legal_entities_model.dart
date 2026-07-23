import '../../domain/entities/paginated_legal_entities.dart';
import 'legal_entity_model.dart';

class PaginatedLegalEntitiesModel extends PaginatedLegalEntities {
  const PaginatedLegalEntitiesModel({
    required super.items,
    required super.totalItems,
    required super.totalPages,
    required super.currentPage,
    required super.pageSize,
  });

  factory PaginatedLegalEntitiesModel.fromJson(Map<String, dynamic> json) {
    return PaginatedLegalEntitiesModel(
      items: (json['items'] as List)
          .map((item) => LegalEntityModel.fromJson(item))
          .toList(),
      totalItems: json['total_items'],
      totalPages: json['total_pages'],
      currentPage: json['current_page'],
      pageSize: json['page_size'],
    );
  }

  PaginatedLegalEntities toEntity() {
    return PaginatedLegalEntities(
      items: items
          .map((model) => (model as LegalEntityModel).toEntity())
          .toList(),
      totalItems: totalItems,
      totalPages: totalPages,
      currentPage: currentPage,
      pageSize: pageSize,
    );
  }
}
