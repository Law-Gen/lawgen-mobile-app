// lib/data/models/paginated_response_model.dart

import '../../domain/entities/paginated_response.dart';

/// A generic model for handling paginated API responses.
/// It extends the PaginatedResponse entity.
class PaginatedResponseModel<T> extends PaginatedResponse<T> {
  const PaginatedResponseModel({
    required super.items,
    required super.totalItems,
    required super.totalPages,
    required super.currentPage,
  });

  /// Creates a PaginatedResponseModel from a JSON map.
  /// It requires a function `fromJsonT` to know how to convert
  /// the individual items in the list.
  factory PaginatedResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return PaginatedResponseModel<T>(
      items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
      totalItems: json['total_items'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
    );
  }
}
