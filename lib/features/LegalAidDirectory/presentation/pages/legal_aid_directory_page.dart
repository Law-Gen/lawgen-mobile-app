import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection_container.dart';
import '../bloc/legal_aid_bloc.dart';
import '../widgets/legal_entity_card.dart';

class LegalAidDirectoryPage extends StatefulWidget {
  const LegalAidDirectoryPage({super.key});

  static Widget withBloc() {
    return BlocProvider(
      create: (context) =>
          LegalAidSL<LegalAidBloc>()..add(const LoadLegalAidDirectoryEvent()),
      child: const LegalAidDirectoryPage(),
    );
  }

  @override
  State<LegalAidDirectoryPage> createState() => _LegalAidDirectoryPageState();
}

class _LegalAidDirectoryPageState extends State<LegalAidDirectoryPage> {
  final _searchController = TextEditingController();
  final List<String> _filterOptions = const [
    'All',
    'Law Firm',
    'Legal Aid',
    'Pro Bono',
    'Government',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<LegalAidBloc>().add(
        SearchQueryChangedEvent(_searchController.text),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = context.select(
      (LegalAidBloc bloc) => bloc.state.selectedFilterType,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F5F3),
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Legal Aid Directory",
              style: TextStyle(color: Colors.black87, fontSize: 20),
            ),
            Text(
              "Find legal assistance near you",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(selectedFilter),
          Expanded(
            child: BlocBuilder<LegalAidBloc, LegalAidState>(
              builder: (context, state) {
                if (state.status == LegalAidStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == LegalAidStatus.failure) {
                  return Center(child: Text(state.errorMessage));
                }
                if (state.filteredEntities.isEmpty &&
                    state.status == LegalAidStatus.success) {
                  return const Center(child: Text("No results found."));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: state.filteredEntities.length,
                  itemBuilder: (context, index) {
                    return LegalEntityCard(
                      entity: state.filteredEntities[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, specialty, or location...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(String selectedFilter) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: _filterOptions.map((option) {
          final isSelected = selectedFilter == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) {
                context.read<LegalAidBloc>().add(
                  FilterTypeChangedEvent(option),
                );
              },
              selectedColor: Colors.brown.shade700,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
              backgroundColor: Colors.white,
              shape: StadiumBorder(
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
