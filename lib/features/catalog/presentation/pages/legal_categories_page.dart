import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/legal_document.dart';
import '../../injection_container.dart';
import '../bloc/legal_content_bloc.dart';

// -- Konstanta Desain --
const Color kBackgroundColor = Color(0xFFFFF8F6);
const Color kPrimaryTextColor = Color(0xFF4A4A4A);
const Color kSecondaryTextColor = Color(0xFF7A7A7A);
const Color kCardBackgroundColor = Colors.white;
const Color kButtonColor = Color(0xFF8B572A);
const Color kShadowColor = Color(0xFFD3C1B3);

class LegalCategoriesPage extends StatelessWidget {
  const LegalCategoriesPage({super.key});

  /// Metode factory untuk menyediakan BLoC secara otomatis
  static Widget withBloc() {
    return BlocProvider(
      create: (_) =>
          catalogSL<LegalContentBloc>()..add(const LoadLegalCategoriesEvent()),
      child: const LegalCategoriesPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: const Text(
          'Legal Categories',
          style: TextStyle(
            color: kPrimaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryTextColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<LegalContentBloc, LegalContentState>(
        builder: (context, state) {
          if (state is LegalContentLoading) {
            return const Center(
              child: CircularProgressIndicator(color: kButtonColor),
            );
          }
          if (state is LegalContentError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: kSecondaryTextColor),
              ),
            );
          }
          if (state is LegalCategoriesLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                return _CategoryCard(category: state.categories[index]);
              },
            );
          }
          return const Center(
            child: Text(
              'Explore legal topics.',
              style: TextStyle(color: kSecondaryTextColor),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final LegalDocument category;

  const _CategoryCard({required this.category});

  // Karena API tidak menyediakan data ini, kami menggunakan placeholder
  // atau logika sederhana berdasarkan nama kategori.
  Map<String, dynamic> _getDisplayData(String categoryName) {
    if (categoryName.toLowerCase().contains('employment')) {
      return {'icon': Icons.work, 'topics': 12, 'level': 'beginner'};
    }
    if (categoryName.toLowerCase().contains('family')) {
      return {'icon': Icons.people, 'topics': 15, 'level': 'intermediate'};
    }
    if (categoryName.toLowerCase().contains('property')) {
      return {'icon': Icons.home, 'topics': 10, 'level': 'intermediate'};
    }
    return {'icon': Icons.business, 'topics': 8, 'level': 'advanced'};
  }

  @override
  Widget build(BuildContext context) {
    final displayData = _getDisplayData(category.name);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: kCardBackgroundColor,
      elevation: 4,
      shadowColor: kShadowColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(displayData['icon'], size: 40, color: kButtonColor),
            const SizedBox(height: 16),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kPrimaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.description,
              style: const TextStyle(fontSize: 14, color: kSecondaryTextColor),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TagChip(
                  text: '${displayData['topics']} topics',
                  color: Colors.grey.shade200,
                ),
                const SizedBox(width: 8),
                TagChip(
                  text: displayData['level'],
                  color: Colors.yellow.shade200,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi ke halaman artikel, meneruskan ID dan nama
                  context.push(
                    '/articles/${category.id}',
                    extra: category.name,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Explore Topics',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  final String text;
  final Color color;
  const TagChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: kPrimaryTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
