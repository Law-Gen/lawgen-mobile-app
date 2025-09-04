import '../../domain/entities/paginated_legal_documents.dart';
import 'legal_document_model.dart';

class PaginatedLegalDocumentsModel extends PaginatedLegalDocuments {
  const PaginatedLegalDocumentsModel({
    required super.items,
    required super.totalItems,
    required super.totalPages,
    required super.currentPage,
    required super.pageSize,
  });

  factory PaginatedLegalDocumentsModel.fromJson(Map<String, dynamic> json) {
    return PaginatedLegalDocumentsModel(
      items: (json['items'] as List)
          .map(
            (item) => LegalDocumentModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      totalItems: json['total_items'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
      pageSize: json['page_size'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': (items as List<LegalDocumentModel>)
          .map((item) => item.toJson())
          .toList(),
      'total_items': totalItems,
      'total_pages': totalPages,
      'current_page': currentPage,
      'page_size': pageSize,
    };
  }

  PaginatedLegalDocuments toEntity() {
    return PaginatedLegalDocuments(
      items: items
          .map((item) => (item as LegalDocumentModel).toEntity())
          .toList(),
      totalItems: totalItems,
      totalPages: totalPages,
      currentPage: currentPage,
      pageSize: pageSize,
    );
  }
}
