import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/question.dart';
import '../../domain/entities/quize.dart';

// -- Design Constants (New Palette) --
const Color kBackgroundColor = Color(0xFFFFF8F6);
const Color kPrimaryTextColor = Color(0xFF4A4A4A);
const Color kSecondaryTextColor = Color(0xFF7A7A7A);
const Color kCardBackgroundColor = Colors.white;
const Color kButtonColor = Color(0xFF8B572A);
const Color kShadowColor = Color(0xFFD3C1B3);

// Complementary colors for the new palette
const Color kCorrectColor = Color(0xFF34D399); // A complementary green
const Color kIncorrectColor = Color(0xFFF87171); // A complementary red

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
    // <-- 'context' is defined here
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
      backgroundColor: kBackgroundColor,
      appBar: _buildAppBar(context, quiz.name),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // MODIFICATION 1: Pass the context to the method
              _buildScoreCard(context, percentage),
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
    // ... (this method already correctly accepts context, no changes needed)
    return AppBar(
      backgroundColor: kBackgroundColor,
      elevation: 0,
      leading: TextButton.icon(
        onPressed: () => context.go('/quiz'), // This one is correct
        icon: const Icon(Icons.arrow_back, color: kSecondaryTextColor),
        label: const Text(
          'Back to Quizzes',
          style: TextStyle(fontFamily: 'Inter', color: kSecondaryTextColor),
        ),
      ),
      leadingWidth: 150,
      title: Column(
        children: [
          const Text(
            'Quiz Results',
            style: TextStyle(
              fontFamily: 'Inter',
              color: kPrimaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            quizName,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: kSecondaryTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: kShadowColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'EN',
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

  // MODIFICATION 2: Update the method to accept context
  Widget _buildScoreCard(BuildContext context, double percentage) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kShadowColor.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ... (no changes to the Text and ProgressIndicator widgets)
          const Text(
            'Keep Learning!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You completed the quiz successfully.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: kSecondaryTextColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: kButtonColor,
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
                backgroundColor: kBackgroundColor,
                valueColor: const AlwaysStoppedAnimation<Color>(kButtonColor),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  side: const BorderSide(color: kButtonColor, width: 1.5),
                ),
                child: const Text(
                  'Review Quiz',
                  style: TextStyle(
                    color: kButtonColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                // Now this call is valid because 'context' is in scope
                onPressed: () => context.go('/quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonColor,
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

  // ... (no changes needed for _buildQuestionReviewCard or _buildAnswerOption)
  Widget _buildQuestionReviewCard(Question question) {
    final userAnswerKey = userAnswers[question.id];
    final bool isCorrect = userAnswerKey == question.correctOption;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kShadowColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? kCorrectColor : kIncorrectColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.text,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryTextColor,
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
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              // NOTE: Assumes your Question entity has an 'explanation' field.
              "Explanation: ${'No explanation provided.'}",
              style: const TextStyle(
                fontFamily: 'Inter',
                color: kSecondaryTextColor,
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
    Color textColor = kSecondaryTextColor;

    if (optionKey == correctOptionKey) {
      backgroundColor = kCorrectColor.withOpacity(0.1);
      textColor = kCorrectColor;
    } else if (optionKey == userAnswerKey) {
      backgroundColor = kIncorrectColor.withOpacity(0.1);
      textColor = kIncorrectColor;
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
