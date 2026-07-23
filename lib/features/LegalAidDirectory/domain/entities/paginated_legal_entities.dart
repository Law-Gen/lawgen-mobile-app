import 'package:equatable/equatable.dart';
import 'legal_entity.dart';

class PaginatedLegalEntities extends Equatable {
  final List<LegalEntity> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  const PaginatedLegalEntities({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  @override
  List<Object> get props => [items, totalItems, totalPages, currentPage];
}
