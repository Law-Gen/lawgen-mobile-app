import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../quiz_injection.dart';
import '../bloc/quiz_bloc.dart';

// -- Design Constants (New Palette) --
const Color kBackgroundColor = Color(0xFFFFF8F6);
const Color kPrimaryTextColor = Color(0xFF4A4A4A);
const Color kSecondaryTextColor = Color(0xFF7A7A7A);
const Color kCardBackgroundColor = Colors.white;
const Color kButtonColor = Color(0xFF8B572A);
const Color kShadowColor = Color(0xFFD3C1B3);

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  /// Factory method to provide the bloc automatically
  static Widget withBloc() {
    return BlocProvider(
      create: (_) => quizSl<QuizBloc>()..add(const LoadQuizCategoriesEvent()),
      child: const QuizHomePage(),
    );
  }

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: const Column(
          children: [
            Text(
              'የህግ ጥያቄዎች', // "Legal Questions" in Amharic
              style: TextStyle(
                fontFamily: 'Noto Sans Ethiopic',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: kPrimaryTextColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Test Your Knowledge',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.normal,
                color: kSecondaryTextColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 80,
      ),
      // --- WRAPPED WITH BLOCLISTENER TO HANDLE INITIAL SELECTION ---
      body: BlocListener<QuizBloc, QuizState>(
        listener: (context, state) {
          // This is the new logic.
          // When categories are loaded for the first time (detected by
          // selectedCategoryId being null) and the category list isn't empty,
          // it automatically dispatches an event to load quizzes for the first category.
          if (state is QuizCategoriesLoaded &&
              state.selectedCategoryId == null &&
              state.categories.isNotEmpty) {
            context.read<QuizBloc>().add(
              LoadQuizzesByCategoryEvent(categoryId: state.categories.first.id),
            );
          }
        },
        child: BlocBuilder<QuizBloc, QuizState>(
          builder: (context, state) {
            if (state is QuizCategoriesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: kButtonColor),
              );
            }
            if (state is QuizError) {
              return Center(child: Text(state.message));
            }
            if (state is QuizCategoriesLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildCategoryChips(state),
                  const SizedBox(height: 30),
                  Expanded(child: _buildQuizList(state)),
                ],
              );
            }
            // Fallback for any other unhandled state
            return const Center(child: Text('Select a category to start'));
          },
        ),
      ),
    );
  }

  /// Builds the horizontally scrolling custom category chips.
  Widget _buildCategoryChips(QuizCategoriesLoaded state) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          final bool isSelected = state.selectedCategoryId == category.id;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () {
                // No change here, still loads quizzes on manual tap
                context.read<QuizBloc>().add(
                  LoadQuizzesByCategoryEvent(categoryId: category.id),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? kButtonColor : kCardBackgroundColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? kButtonColor.withOpacity(0.4)
                          : kShadowColor.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isSelected ? Colors.transparent : kShadowColor,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : kPrimaryTextColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the list of quizzes with a new, more engaging card design.
  Widget _buildQuizList(QuizCategoriesLoaded state) {
    // This will now show a loading indicator for quizzes after categories load
    if (state.isQuizzesLoading) {
      return const Center(
        child: CircularProgressIndicator(color: kButtonColor),
      );
    }

    if (state.quizzes.isEmpty && state.selectedCategoryId != null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No quizzes available for this category yet. Please check back later!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              color: kSecondaryTextColor,
            ),
          ),
        ),
      );
    }

    // This handles the initial state before the listener fires
    if (state.quizzes.isEmpty && state.selectedCategoryId == null) {
      return const SizedBox.shrink(); // Show nothing briefly while quizzes load
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      itemCount: state.quizzes.length,
      itemBuilder: (context, index) {
        final quiz = state.quizzes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: kCardBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: kShadowColor.withOpacity(0.6),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kButtonColor, kButtonColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(Icons.school, size: 60, color: Colors.white54),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoTag(
                          Icons.help_outline_rounded,
                          quiz.totalQuestion,
                        ),
                        const SizedBox(width: 16),
                        _buildInfoTag(Icons.timer_outlined, '${10} Min'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () {
                          context.push('/quiz/${quiz.id}');
                        },
                        child: const Text(
                          'Start Quiz',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper widget for creating small, styled info tags.
  Widget _buildInfoTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kShadowColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kSecondaryTextColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kSecondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
