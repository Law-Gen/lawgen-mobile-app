import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/legal_entity.dart';
import '../../domain/usecases/get_legal_entities_usecase.dart';
import '../../../../core/usecases/usecase.dart'; // Core usecase for NoParams if needed

part 'legal_aid_event.dart';
part 'legal_aid_state.dart';

class LegalAidBloc extends Bloc<LegalAidEvent, LegalAidState> {
  final GetLegalEntitiesUsecase _getLegalEntities;

  LegalAidBloc({required GetLegalEntitiesUsecase getLegalEntities})
    : _getLegalEntities = getLegalEntities,
      super(const LegalAidState()) {
    on<LoadLegalAidDirectoryEvent>(_onLoadDirectory);
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<FilterTypeChangedEvent>(_onFilterTypeChanged);
  }

  Future<void> _onLoadDirectory(
    LoadLegalAidDirectoryEvent event,
    Emitter<LegalAidState> emit,
  ) async {
    emit(state.copyWith(status: LegalAidStatus.loading));
    final result = await _getLegalEntities(
      const GetLegalEntitiesParams(page: 1, pageSize: 50), // Load a good number
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LegalAidStatus.failure,
          errorMessage: 'Failed to load directory.',
        ),
      ),
      (paginatedData) => emit(
        state.copyWith(
          status: LegalAidStatus.success,
          allEntities: paginatedData.items,
          filteredEntities: paginatedData.items, // Initially, show all
        ),
      ),
    );
  }

  void _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<LegalAidState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
    _applyFilters(emit);
  }

  void _onFilterTypeChanged(
    FilterTypeChangedEvent event,
    Emitter<LegalAidState> emit,
  ) {
    emit(state.copyWith(selectedFilterType: event.filterType));
    _applyFilters(emit);
  }

  void _applyFilters(Emitter<LegalAidState> emit) {
    final filteredList = state.allEntities.where((entity) {
      // Type Filter Logic
      final typeFilter = state.selectedFilterType;
      bool matchesType =
          typeFilter == 'All' ||
          _formatEntityType(entity.entityType) == typeFilter;

      // Search Query Logic
      final query = state.searchQuery.toLowerCase();
      bool matchesSearch =
          query.isEmpty ||
          entity.name.toLowerCase().contains(query) ||
          entity.description.toLowerCase().contains(query) ||
          entity.servicesOffered.any((s) => s.toLowerCase().contains(query)) ||
          entity.city.toLowerCase().contains(query) ||
          entity.subCity.toLowerCase().contains(query);

      return matchesType && matchesSearch;
    }).toList();

    emit(state.copyWith(filteredEntities: filteredList));
  }

  // Helper to format entity type for display and filtering
  String _formatEntityType(String apiType) {
    switch (apiType) {
      case 'PRIVATE_LAW_FIRM':
        return 'Law Firm';
      case 'LEGAL_AID_ORGANIZATION':
        return 'Legal Aid';
      // Add other cases as needed
      default:
        return 'Other';
    }
  }
}
