import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/question.dart';
import '../../domain/entities/quize.dart';

// Design System Colors
const Color PRIMARY_COLOR = Color.fromARGB(92, 101, 67, 33); // deep brown (chocolate-like)
const Color BACKGROUND_COLOR = Color(0xFFF0F4F8);
const Color ACCENT_COLOR = Color(0xFF2EC4B6);
const Color TEXT_COLOR_PRIMARY = Color(0xFF374151);
const Color TEXT_COLOR_SECONDARY = Color(0xFF6B7280);
const Color BORDER_COLOR = Color(0xFFE5E7EB);
const Color CORRECT_COLOR = Color(0xFF2EC4B6); // Teal for correct
const Color INCORRECT_COLOR = Color(0xFFEF4444); // Red for incorrect

class QuizResultPage extends StatelessWidget {
  final Quiz quiz;
  final Map<String, String> userAnswers;

  const QuizResultPage({
    Key? key,
    required this.quiz,
    required this.userAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int score = 0;
    userAnswers.forEach((questionId, answer) {
      if (quiz.questions.firstWhere((q) => q.id == questionId).correctOption ==
          answer) {
        score++;
      }
    });
    final int total = quiz.questions.length;
    final double percentage = total > 0 ? (score / total) * 100 : 0;

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: _buildAppBar(context, quiz.name),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildScoreCard(percentage),
              const SizedBox(height: 24),
              ...quiz.questions.map((question) {
                return _buildQuestionReviewCard(question);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String quizName) {
    return AppBar(
      backgroundColor: BACKGROUND_COLOR,
      elevation: 0,
      leading: TextButton.icon(
        onPressed: () => context.go('/'), // Navigate to home or categories
        icon: const Icon(Icons.arrow_back, color: TEXT_COLOR_SECONDARY),
        label: const Text(
          'Back to Quizzes',
          style: TextStyle(fontFamily: 'Inter', color: TEXT_COLOR_SECONDARY),
        ),
      ),
      leadingWidth: 150,
      title: Column(
        children: [
          const Text(
            'Quiz Results',
            style: TextStyle(
              fontFamily: 'Inter',
              color: PRIMARY_COLOR,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            quizName,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: TEXT_COLOR_SECONDARY,
              fontSize: 14,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        // Placeholder for language switcher
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: BORDER_COLOR),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'EN',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              color: PRIMARY_COLOR,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(double percentage) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Keep Learning!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: PRIMARY_COLOR,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You completed the quiz successfully.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: TEXT_COLOR_SECONDARY,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: PRIMARY_COLOR,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 10,
                backgroundColor: BACKGROUND_COLOR,
                valueColor: const AlwaysStoppedAnimation<Color>(PRIMARY_COLOR),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {}, // Placeholder
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  side: const BorderSide(color: PRIMARY_COLOR, width: 1.5),
                ),
                child: const Text(
                  'Review Quiz',
                  style: TextStyle(
                    color: PRIMARY_COLOR,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {}, // Placeholder
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Try Another Quiz',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionReviewCard(Question question) {
    final userAnswerKey = userAnswers[question.id];
    final bool isCorrect = userAnswerKey == question.correctOption;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? CORRECT_COLOR : INCORRECT_COLOR,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.text,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TEXT_COLOR_PRIMARY,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...question.options.entries.map((entry) {
            return _buildAnswerOption(
              entry,
              userAnswerKey,
              question.correctOption,
            );
          }).toList(),
          const SizedBox(height: 12),
          // Explanation section
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: BACKGROUND_COLOR,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              // NOTE: Assumes your Question entity has an 'explanation' field.
              "Explanation: ${'No explanation provided.'}",
              style: const TextStyle(
                fontFamily: 'Inter',
                color: TEXT_COLOR_SECONDARY,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(
    MapEntry<String, String> option,
    String? userAnswerKey,
    String correctOptionKey,
  ) {
    final optionKey = option.key;
    final optionText = option.value;

    Color backgroundColor = Colors.transparent;
    Color textColor = TEXT_COLOR_SECONDARY;

    if (optionKey == correctOptionKey) {
      backgroundColor = CORRECT_COLOR.withOpacity(0.1);
      textColor = CORRECT_COLOR;
    } else if (optionKey == userAnswerKey) {
      backgroundColor = INCORRECT_COLOR.withOpacity(0.1);
      textColor = INCORRECT_COLOR;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        optionText,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
