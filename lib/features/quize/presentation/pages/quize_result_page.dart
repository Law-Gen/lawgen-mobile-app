import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizResultPage extends StatelessWidget {
  final int score;
  final int total;

  const QuizResultPage({Key? key, required this.score, required this.total})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double scorePercent = (score / total) * 100;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                "Quiz Results",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Card with trophy + score
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.teal[100],
                      radius: 30,
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.teal,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Great Job!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$score / $total",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("correct!"),
                    const SizedBox(height: 12),

                    // Progress bar
                    LinearProgressIndicator(
                      value: score / total,
                      backgroundColor: Colors.grey[200],
                      color: Colors.teal,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text("Your Score: ${scorePercent.toStringAsFixed(1)}%"),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Buttons
              ElevatedButton(
                onPressed: () {
                  context.go('/quiz'); // back to quiz topics
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Back to Topics"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
