part of 'legal_content_bloc.dart';

abstract class LegalContentState extends Equatable {
  const LegalContentState();

  @override
  List<Object> get props => [];
}

class LegalContentInitial extends LegalContentState {}

class LegalContentLoading extends LegalContentState {}

/// Status saat kategori berhasil dimuat.
class LegalCategoriesLoaded extends LegalContentState {
  final List<LegalDocument> categories;

  const LegalCategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

/// Status saat artikel berhasil dimuat.
class LegalArticlesLoaded extends LegalContentState {
  final List<LegalDocument> articles;

  const LegalArticlesLoaded(this.articles);

  @override
  List<Object> get props => [articles];
}

/// Status jika terjadi kesalahan.
class LegalContentError extends LegalContentState {
  final String message;

  const LegalContentError(this.message);

  @override
  List<Object> get props => [message];
}
