part of 'legal_aid_bloc.dart';

enum LegalAidStatus { initial, loading, success, failure }

class LegalAidState extends Equatable {
  const LegalAidState({
    this.status = LegalAidStatus.initial,
    this.allEntities = const <LegalEntity>[],
    this.filteredEntities = const <LegalEntity>[],
    this.selectedFilterType = 'All',
    this.searchQuery = '',
    this.errorMessage = '',
  });

  final LegalAidStatus status;
  final List<LegalEntity> allEntities;
  final List<LegalEntity> filteredEntities;
  final String selectedFilterType;
  final String searchQuery;
  final String errorMessage;

  LegalAidState copyWith({
    LegalAidStatus? status,
    List<LegalEntity>? allEntities,
    List<LegalEntity>? filteredEntities,
    String? selectedFilterType,
    String? searchQuery,
    String? errorMessage,
  }) {
    return LegalAidState(
      status: status ?? this.status,
      allEntities: allEntities ?? this.allEntities,
      filteredEntities: filteredEntities ?? this.filteredEntities,
      selectedFilterType: selectedFilterType ?? this.selectedFilterType,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
    status,
    allEntities,
    filteredEntities,
    selectedFilterType,
    searchQuery,
    errorMessage,
  ];
}
