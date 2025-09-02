import 'package:equatable/equatable.dart';

/// No parameters (e.g., when not needed)
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

/// For requests that need an ID (quizId, categoryId, etc.)
class IdParams extends Equatable {
  final String id;

  const IdParams(this.id);

  @override
  List<Object?> get props => [id];
}

/// For pagination only
class PageParams extends Equatable {
  final int page;
  final int limit;

  const PageParams({required this.page, required this.limit});

  @override
  List<Object?> get props => [page, limit];
}

/// For category + pagination
class CategoryPageParams extends Equatable {
  final String categoryId;
  final int page;
  final int limit;

  const CategoryPageParams({
    required this.categoryId,
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [categoryId, page, limit];
}
