import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// -- Design Constants --
const Color kBackgroundColor = Color(0xFFFFF8F6);
const Color kPrimaryTextColor = Color(0xFF4A4A4A);
const Color kSecondaryTextColor = Color(0xFF7A7A7A);
const Color kCardBackgroundColor = Colors.white;
const Color kButtonColor = Color(0xFF8B572A);
const Color kShadowColor = Color(0xFFD3C1B3);

class SuccessResetPage extends StatelessWidget {
  const SuccessResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    void navigateToSignIn() {
      context.go('/signin');
    }

    // Helper function for button styling to maintain consistency
    ButtonStyle primaryButtonStyle() => ElevatedButton.styleFrom(
      backgroundColor: kButtonColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: kShadowColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );

    return Scaffold(
      backgroundColor: kBackgroundColor, // UPDATED
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Ensures button stretches
            children: [
              const Icon(
                Icons.check_circle_outline, // Using outline for a lighter feel
                color: Color(0xFF2E7D32), // A slightly deeper green
                size: 100,
              ),
              const SizedBox(height: 32),
              const Text(
                "Password Reset Successful!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor, // UPDATED
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "You can now sign in with your new password.", // Simplified text
                style: TextStyle(
                  fontSize: 16,
                  color: kSecondaryTextColor, // UPDATED
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: navigateToSignIn,
                style: primaryButtonStyle(), // UPDATED
                child: const Text(
                  'Back to Sign In', // More descriptive text
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
