import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/legal_document.dart';
import '../../domain/usecases/get_legal_documents_by_category_id_usecase.dart';
import '../../domain/usecases/get_legal_documents_usecase.dart';

part 'legal_content_event.dart';
part 'legal_content_state.dart';

class LegalContentBloc extends Bloc<LegalContentEvent, LegalContentState> {
  final GetLegalDocumentsUsecase getLegalDocuments;
  final GetLegalDocumentsByCategoryIdUsecase getLegalDocumentsByCategoryId;

  LegalContentBloc({
    required this.getLegalDocuments,
    required this.getLegalDocumentsByCategoryId,
  }) : super(LegalContentInitial()) {
    on<LoadLegalCategoriesEvent>(_onLoadLegalCategories);
    on<LoadLegalArticlesEvent>(_onLoadLegalArticles);
  }

  Future<void> _onLoadLegalCategories(
    LoadLegalCategoriesEvent event,
    Emitter<LegalContentState> emit,
  ) async {
    emit(LegalContentLoading());
    final result = await getLegalDocuments(
      GetLegalDocumentsParams(page: event.page, pageSize: event.pageSize),
    );

    result.fold(
      (failure) => emit(LegalContentError(_mapFailureToMessage(failure))),
      (paginatedResult) => emit(LegalCategoriesLoaded(paginatedResult.items)),
    );
  }

  Future<void> _onLoadLegalArticles(
    LoadLegalArticlesEvent event,
    Emitter<LegalContentState> emit,
  ) async {
    emit(LegalContentLoading());
    final result = await getLegalDocumentsByCategoryId(
      GetLegalDocumentsByCategoryIdParams(id: event.categoryId),
    );

    result.fold(
      (failure) => emit(LegalContentError(_mapFailureToMessage(failure))),
      (articles) => emit(LegalArticlesLoaded(articles)),
    );
  }
}

// Helper untuk memetakan Kegagalan ke pesan yang dapat dibaca pengguna
const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String NETWORK_FAILURE_MESSAGE = 'No Internet Connection';

String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return SERVER_FAILURE_MESSAGE;
    case NetworkFailure:
      return NETWORK_FAILURE_MESSAGE;
    default:
      return 'Unexpected Error';
  }
}
