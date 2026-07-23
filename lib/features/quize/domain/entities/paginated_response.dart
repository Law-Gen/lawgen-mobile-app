import 'package:equatable/equatable.dart';

class PaginatedResponse<T> extends Equatable {
  final List<T> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  const PaginatedResponse({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [items, totalItems, totalPages, currentPage];
}
