import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/question.dart';
import '../../domain/entities/quize.dart';
import '../../quiz_injection.dart';
import '../bloc/quiz_bloc.dart';

// -- Design Constants (New Palette) --
const Color kBackgroundColor = Color(0xFFFFF8F6);
const Color kPrimaryTextColor = Color(0xFF4A4A4A);
const Color kSecondaryTextColor = Color(0xFF7A7A7A);
const Color kCardBackgroundColor = Colors.white;
const Color kButtonColor = Color(0xFF8B572A);
const Color kShadowColor = Color(0xFFD3C1B3);

// Derived constants for consistency
const Color kAccentColor = kButtonColor; // Use the button color for highlights
const Color kBorderColor = kShadowColor; // Use the shadow color for borders

class QuizQuestionPage extends StatefulWidget {
  final String quizId;

  const QuizQuestionPage({super.key, required this.quizId});

  static Widget withBloc(String quizId) {
    return BlocProvider(
      create: (_) => quizSl<QuizBloc>()..add(GetQuizByIdEvent(quizId: quizId)),
      child: QuizQuestionPage(quizId: quizId),
    );
  }

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  int _currentIndex = 0;
  final Map<String, String> _selectedAnswers = {};

  void _selectOption(String questionId, String optionKey) {
    setState(() {
      _selectedAnswers[questionId] = optionKey;
    });
  }

  void _submitQuiz(Quiz quiz) {
    // Navigate and pass the full quiz and user answers for the results page
    context.push(
      '/quiz/${quiz.id}/results',
      extra: {'quiz': quiz, 'userAnswers': _selectedAnswers},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _buildAppBar(),
      body: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          if (state is QuizeQuestionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: kButtonColor),
            );
          }
          if (state is QuizError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is QuizLoaded) {
            final quiz = state.quiz;
            if (quiz.questions.isEmpty) {
              return const Center(child: Text('No questions available.'));
            }
            return _buildQuizBody(quiz);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kBackgroundColor,
      elevation: 0,
      leading: TextButton.icon(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back, color: kSecondaryTextColor),
        label: const Text(
          "Exit Quiz",
          style: TextStyle(fontFamily: 'Inter', color: kSecondaryTextColor),
        ),
      ),
      leadingWidth: 120, // Give more space for the label
      title: BlocSelector<QuizBloc, QuizState, String>(
        selector: (state) => state is QuizLoaded ? state.quiz.name : "",
        builder: (context, quizName) {
          return Column(
            children: [
              Text(
                quizName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: kPrimaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Question ${_currentIndex + 1} of ...", // Placeholder, updated in body
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: kSecondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          );
        },
      ),
      centerTitle: true,
      actions: [
        // Placeholder for language switcher
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: kBorderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "EN",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              color: kPrimaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizBody(Quiz quiz) {
    final Question currentQuestion = quiz.questions[_currentIndex];
    final int totalQuestions = quiz.questions.length;
    final double progress = (_currentIndex + 1) / totalQuestions;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800,
        ), // Max width for web/tablet
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: kCardBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kShadowColor,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressBar(progress),
              const SizedBox(height: 32),
              _buildQuestion(currentQuestion),
              const SizedBox(height: 24),
              Expanded(child: _buildOptions(currentQuestion)),
              _buildNavigation(quiz),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Progress",
              style: TextStyle(
                fontFamily: 'Inter',
                color: kPrimaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(
                fontFamily: 'Inter',
                color: kPrimaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: kBackgroundColor,
            valueColor: const AlwaysStoppedAnimation<Color>(kButtonColor),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion(Question question) {
    return Text(
      question.text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: kPrimaryTextColor,
      ),
    );
  }

  Widget _buildOptions(Question question) {
    final String? selectedOptionKey = _selectedAnswers[question.id];

    return ListView(
      children: question.options.entries.map((entry) {
        final isSelected = selectedOptionKey == entry.key;
        return GestureDetector(
          onTap: () => _selectOption(question.id, entry.key),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? kAccentColor.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? kAccentColor : kBorderColor,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked_outlined,
                  color: isSelected ? kAccentColor : kSecondaryTextColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: kPrimaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigation(Quiz quiz) {
    final bool isLastQuestion = _currentIndex == quiz.questions.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _currentIndex > 0
              ? () => setState(() => _currentIndex--)
              : null,
          child: const Text(
            "Previous",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kSecondaryTextColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (isLastQuestion) {
              _submitQuiz(quiz);
            } else {
              setState(() => _currentIndex++);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kButtonColor,
            foregroundColor: Colors.white, // White text on the dark button
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isLastQuestion ? 'Submit' : 'Next Question',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
