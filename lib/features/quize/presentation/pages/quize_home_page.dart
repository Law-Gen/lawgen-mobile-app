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
      // Use the specified background color.
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'የህግ ጥያቄዎች', // "Legal Questions" in Amharic
              style: TextStyle(
                fontFamily: 'Noto Sans Ethiopic',
                fontSize: 26, // Larger header font size
                fontWeight: FontWeight.bold,
                color: kPrimaryTextColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Test Your Knowledge',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17, // Base body font size
                fontWeight: FontWeight.normal,
                color: kPrimaryTextColor,
              ),
            ),
          ],
        ),
        centerTitle: false,
        toolbarHeight: 80,
      ),
      body: BlocBuilder<QuizBloc, QuizState>(
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
                // Category chips
                SizedBox(
                  height: 60,
                  child: Center(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        final bool isSelected =
                            state.selectedCategoryId == category.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: ChoiceChip(
                            label: Text(category.name),
                            labelStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : kPrimaryTextColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              context.read<QuizBloc>().add(
                                LoadQuizzesByCategoryEvent(
                                  categoryId: category.id,
                                ),
                              );
                            },
                            // Use Button color for selected chip
                            selectedColor: kButtonColor,
                            backgroundColor: kCardBackgroundColor,
                            elevation: isSelected ? 4.0 : 1.0,
                            pressElevation: 6.0,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : kShadowColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // This widget handles the display of quizzes or a loading indicator
                Expanded(child: _buildQuizList(state)),
              ],
            );
          }
          // Fallback for any other unhandled state
          return const Center(child: Text('Select a category to start'));
        },
      ),
    );
  }

  /// Builds the list of quizzes or a loading/empty state.
  Widget _buildQuizList(QuizCategoriesLoaded state) {
    if (state.isQuizzesLoading) {
      return const Center(
        child: CircularProgressIndicator(color: kButtonColor),
      );
    }

    if (state.quizzes.isEmpty) {
      return const Center(
        child: Text(
          'No quizzes found in this category.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            color: kSecondaryTextColor,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.quizzes.length,
      itemBuilder: (context, index) {
        final quiz = state.quizzes[index];
        return Card(
          color: kCardBackgroundColor,
          shadowColor: kShadowColor,
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header/Icon Section
              Container(
                height: 120,
                width: double.infinity,
                color: kButtonColor.withOpacity(0.05),
                child: const Center(
                  child: Icon(
                    Icons.school_outlined,
                    size: 50,
                    color: kButtonColor,
                  ),
                ),
              ),
              // Content Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Quiz Title
                    Text(
                      quiz.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22, // Larger font size for title
                        fontWeight: FontWeight.bold,
                        color: kPrimaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quiz Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.help_outline,
                          size: 18,
                          color: kSecondaryTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          quiz.totalQuestion,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: kSecondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 24),
                        const Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: kSecondaryTextColor,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '${10} Min',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: kSecondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Action Button
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kButtonColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () {
                          context.push('/quiz/${quiz.id}');
                          print('Navigating to quiz with ID: ${quiz.id}');
                        },
                        child: const Text(
                          'Start Quiz',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17, // Base body font size
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
}
