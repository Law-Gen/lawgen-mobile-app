import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/legal_document.dart';
import '../../injection_container.dart';
import '../bloc/legal_content_bloc.dart';
import 'legal_categories_page.dart';

class LegalArticlesPage extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const LegalArticlesPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  /// Metode factory untuk menyediakan BLoC dan mengirimkan event pemuatan awal
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
              categoryName,
              style: const TextStyle(
                color: kPrimaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Rights and responsibilities",
              style: TextStyle(color: kSecondaryTextColor, fontSize: 14),
            ),
          ],
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
          if (state is LegalArticlesLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.articles.length,
              itemBuilder: (context, index) {
                return _ArticleCard(article: state.articles[index]);
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
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final LegalDocument article;
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
    final level = article.name.contains("Discrimination")
        ? "intermediate"
        : "beginner";
    final time = level == "beginner" ? "5 min" : "10 min";

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
                  color: level == "beginner"
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Read Article',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
