part of 'legal_aid_bloc.dart';

abstract class LegalAidEvent extends Equatable {
  const LegalAidEvent();

  @override
  List<Object> get props => [];
}

/// Event to fetch the initial list of legal entities.
class LoadLegalAidDirectoryEvent extends LegalAidEvent {
  const LoadLegalAidDirectoryEvent();
}

/// Event triggered when the user types in the search bar.
class SearchQueryChangedEvent extends LegalAidEvent {
  final String query;
  const SearchQueryChangedEvent(this.query);

  @override
  List<Object> get props => [query];
}

/// Event triggered when the user selects a filter chip.
class FilterTypeChangedEvent extends LegalAidEvent {
  final String filterType;
  const FilterTypeChangedEvent(this.filterType);

  @override
  List<Object> get props => [filterType];
}
