part of 'legal_content_bloc.dart';

abstract class LegalContentEvent extends Equatable {
  const LegalContentEvent();

  @override
  List<Object> get props => [];
}

/// Event untuk memuat daftar kategori hukum.
class LoadLegalCategoriesEvent extends LegalContentEvent {
  final int page;
  final int pageSize;

  const LoadLegalCategoriesEvent({this.page = 1, this.pageSize = 10});

  @override
  List<Object> get props => [page, pageSize];
}

/// Event untuk memuat daftar artikel berdasarkan ID kategori.
class LoadLegalArticlesEvent extends LegalContentEvent {
  final String categoryId;

  const LoadLegalArticlesEvent(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}
