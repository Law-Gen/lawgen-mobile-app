import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../quiz_injection.dart';
import '../bloc/quiz_bloc.dart';

// Design System Colors
const Color PRIMARY_COLOR = Color.fromARGB(92, 55, 33, 20); // deeper brown
const Color BACKGROUND_COLOR = Color(0xFFF0F4F8); // Background (Calm Off-White)
const Color ACCENT_COLOR = Color(0xFF2EC4B6); // Accent (Actionable Teal)
const Color TEXT_COLOR_PRIMARY = Color(0xFF374151); // For main text
const Color TEXT_COLOR_SECONDARY = Color(
  0xFF6B7280,
); // For subtitles and details

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
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: BACKGROUND_COLOR,
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
                color: PRIMARY_COLOR,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Test Your Knowledge',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17, // Base body font size
                fontWeight: FontWeight.normal,
                color: PRIMARY_COLOR,
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
              child: CircularProgressIndicator(color: PRIMARY_COLOR),
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
                              color: isSelected ? Colors.white : PRIMARY_COLOR,
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
                            // Use Accent color for selected chip
                            selectedColor: ACCENT_COLOR,
                            backgroundColor: Colors.white,
                            elevation: isSelected ? 4.0 : 1.0,
                            pressElevation: 6.0,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : PRIMARY_COLOR.withOpacity(0.3),
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
        child: CircularProgressIndicator(color: PRIMARY_COLOR),
      );
    }

    if (state.quizzes.isEmpty) {
      return const Center(
        child: Text(
          'No quizzes found in this category.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            color: TEXT_COLOR_SECONDARY,
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
          color: Colors.white,
          shadowColor: PRIMARY_COLOR.withOpacity(0.1),
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
                color: PRIMARY_COLOR.withOpacity(0.05),
                child: const Center(
                  child: Icon(
                    Icons.school_outlined,
                    size: 50,
                    color: PRIMARY_COLOR,
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
                        color: TEXT_COLOR_PRIMARY,
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
                          color: TEXT_COLOR_SECONDARY,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          quiz.totalQuestion,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: TEXT_COLOR_SECONDARY,
                          ),
                        ),
                        const SizedBox(width: 24),
                        const Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: TEXT_COLOR_SECONDARY,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '${10} Min',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: TEXT_COLOR_SECONDARY,
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
                          // Use Primary color for key actions
                          backgroundColor: PRIMARY_COLOR,
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
                          // Uncomment the line below to enable navigation
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
