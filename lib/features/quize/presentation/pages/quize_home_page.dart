import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../quiz_injection.dart';
import '../bloc/quiz_bloc.dart';

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
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F4F8),
        elevation: 0,
        title: const Text(
          'Pick a Card and Roll the Dice',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D2A4B),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0D2A4B)),
            onPressed: () {
              context.read<QuizBloc>().add(const LoadQuizCategoriesEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<QuizBloc, QuizState>(
        buildWhen: (previous, current) {
          return current is QuizCategoriesLoading ||
              current is QuizCategoriesLoaded;
        },
        builder: (context, state) {
          if (state is QuizCategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuizCategoriesLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chips
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: state.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return ChoiceChip(
                        label: Text(
                          category.name,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                        ),
                        selected: false,
                        onSelected: (_) {
                          context.read<QuizBloc>().add(
                            LoadQuizzesByCategoryEvent(categoryId: category.id),
                          );
                        },
                        selectedColor: const Color(0xFF0D2A4B),
                        backgroundColor: const Color(0xFF2EC4B6),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<QuizBloc, QuizState>(
                    // This child BlocBuilder will now handle its own state changes
                    builder: (context, quizState) {
                      if (quizState is QuizzesByCategoryLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (quizState is QuizzesByCategoryLoaded) {
                        if (quizState.quizzes.isEmpty) {
                          return const Center(child: Text('No quizzes found'));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: quizState.quizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = quizState.quizzes[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Placeholder image
                                    Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF2EC4B6,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.school,
                                          size: 60,
                                          color: Color(0xFF2EC4B6),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      quiz.name,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D2A4B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      // Duration based on number of questions
                                      '${10} Questions | ${10} Min',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2EC4B6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          context.push('/quiz/${quiz.id}');
                                        },
                                        child: const Text(
                                          'Play Now',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                              255,
                                              109,
                                              77,
                                              77,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: Text('Select a category to view quizzes'),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is QuizError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Load categories to start'));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0D2A4B),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
