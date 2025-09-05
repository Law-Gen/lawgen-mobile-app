import 'package:equatable/equatable.dart';
import 'legal_document.dart';

class PaginatedLegalDocuments extends Equatable {
  final List<LegalDocument> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  const PaginatedLegalDocuments({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  @override
  List<Object> get props => [
    items,
    totalItems,
    totalPages,
    currentPage,
    pageSize,
  ];
}
