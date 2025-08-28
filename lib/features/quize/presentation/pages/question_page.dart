import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/quize.dart';
import '../bloc/quiz_bloc.dart';
import '../../domain/entities/question.dart';

class QuizQuestionPage extends StatefulWidget {
  final String quizId;

  const QuizQuestionPage({Key? key, required this.quizId}) : super(key: key);

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  int currentIndex = 0;
  Map<String, String> selectedAnswers = {}; // {questionId: chosenOptionKey}

  @override
  void initState() {
    super.initState();
    // fetch quiz by ID (in case it's not already loaded)
    context.read<QuizBloc>().add(GetQuizByIdEvent(quizId: widget.quizId));
  }

  void _selectOption(String questionId, String optionKey) {
    setState(() {
      selectedAnswers[questionId] = optionKey;
    });
  }

  int _calculateScore(List<Question> questions) {
    int score = 0;
    for (var q in questions) {
      final userAnswer = selectedAnswers[q.id];
      if (userAnswer != null && userAnswer == q.correctOption) {
        score++;
      }
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuizLoaded) {
            final Quiz quiz = state.quiz;
            if (quiz.questions.isEmpty) {
              return const Center(child: Text('No questions available.'));
            }

            final Question question = quiz.questions[currentIndex];
            final String? selected = selectedAnswers[question.id];

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timer + Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Q. ${currentIndex + 1}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text("14:30"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Question Text
                    Text(
                      question.text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Options
                    ...question.options.entries.map((entry) {
                      final optionKey = entry.key;
                      final optionText = entry.value;
                      final bool isSelected = selected == optionKey;

                      return GestureDetector(
                        onTap: () => _selectOption(question.id, optionKey),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.pink[100]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.pink
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            optionText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey[800],
                            ),
                          ),
                        ),
                      );
                    }),

                    const Spacer(),

                    // Navigation Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: currentIndex > 0
                              ? () {
                                  setState(() => currentIndex--);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("Previous"),
                        ),
                        ElevatedButton(
                          onPressed: currentIndex < quiz.questions.length - 1
                              ? () {
                                  setState(() => currentIndex++);
                                }
                              : () {
                                  final score = _calculateScore(quiz.questions);

                                  context.push(
                                    '/results',
                                    extra: {
                                      'score': score,
                                      'total': quiz.questions.length,
                                    },
                                  );
                                },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            currentIndex < quiz.questions.length - 1
                                ? "Next"
                                : "Submit",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else if (state is QuizError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
