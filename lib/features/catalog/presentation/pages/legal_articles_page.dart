import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../catalog_injection.dart'; // Make sure this path is correct
import '../../domain/entities/legal_document.dart';
import '../bloc/legal_content_bloc.dart';
import 'legal_categories_page.dart'; // For color constants and the TagChip widget

// MODIFIED: Converted to a StatefulWidget
class LegalArticlesPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const LegalArticlesPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  static Widget withBloc({
    required String categoryId,
    required String categoryName,
  }) {
    return BlocProvider(
      create: (_) =>
          catalogSL<LegalContentBloc>()
            ..add(LoadLegalArticlesEvent(categoryId)),
      child: LegalArticlesPage(
        categoryId: categoryId,
        categoryName: categoryName,
      ),
    );
  }

  @override
  State<LegalArticlesPage> createState() => _LegalArticlesPageState();
}

class _LegalArticlesPageState extends State<LegalArticlesPage> {
  // NEW: Controller and state for the search query
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // NEW: Listener to update the UI as the user types
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    // NEW: Dispose the controller to prevent memory leaks
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoryName, // Access properties via 'widget.'
              style: const TextStyle(
                color: kPrimaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Rights and responsibilities',
              style: TextStyle(color: kSecondaryTextColor, fontSize: 14),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryTextColor),
          onPressed: () => context.pop(),
        ),
      ),
      // MODIFIED: Wrapped body in a Column to add the search bar
      body: Column(
        children: [
          // NEW: Search Bar UI
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search articles...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: kSecondaryTextColor,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kShadowColor.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kShadowColor.withOpacity(0.5)),
                ),
              ),
            ),
          ),
          // MODIFIED: Expanded the BlocBuilder to fill remaining space
          Expanded(
            child: BlocBuilder<LegalContentBloc, LegalContentState>(
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
                if (state is LegalArticlesLoaded) {
                  // NEW: Filtering Logic
                  final allArticles = state.articles;
                  final filteredArticles = allArticles.where((article) {
                    final titleLower = article.name.toLowerCase();
                    final descriptionLower = article.description.toLowerCase();
                    final searchLower = _searchQuery.toLowerCase();

                    return titleLower.contains(searchLower) ||
                        descriptionLower.contains(searchLower);
                  }).toList();

                  // NEW: Handle "No Results" case
                  if (filteredArticles.isEmpty) {
                    return const Center(
                      child: Text(
                        'No articles found.',
                        style: TextStyle(
                          color: kSecondaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    // Use the filtered list
                    itemCount: filteredArticles.length,
                    itemBuilder: (context, index) {
                      return _ArticleCard(article: filteredArticles[index]);
                    },
                  );
                }
                return const Center(
                  child: Text(
                    'Loading articles...',
                    style: TextStyle(color: kSecondaryTextColor),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// _ArticleCard remains exactly the same.
class _ArticleCard extends StatelessWidget {
  final LegalContent article;
  const _ArticleCard({required this.article});

  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder data
    final level = article.name.contains('Discrimination')
        ? 'intermediate'
        : 'beginner';
    final time = level == 'beginner' ? '5 min' : '10 min';

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: kCardBackgroundColor,
      elevation: 2,
      shadowColor: kShadowColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    article.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryTextColor,
                    ),
                  ),
                ),
                TagChip(
                  text: level,
                  color: level == 'beginner'
                      ? Colors.green.shade100
                      : Colors.yellow.shade200,
                ),
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(color: kSecondaryTextColor)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              article.description,
              style: const TextStyle(color: kSecondaryTextColor, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () => _launchURL(context, article.url),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonColor,
                  minimumSize: const Size(50, 50), // width, height
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // smoother corners
                  ),
                  elevation: 3, // subtle shadow
                ),
                child: const Text(
                  'Read Article',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14, // increased font size
                    fontWeight: FontWeight.w600, // slightly bolder
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
