import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

// -- Design Constants --
const Color kBackgroundColor = Color(0xFFFFF8F6);
const Color kPrimaryTextColor = Color(0xFF4A4A4A);
const Color kSecondaryTextColor = Color(0xFF7A7A7A);
const Color kCardBackgroundColor = Colors.white;
const Color kButtonColor = Color(0xFF8B572A);
const Color kShadowColor = Color(0xFFD3C1B3);

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  // Amharic toggle logic remains unchanged
  bool _isAmharic = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- LOGIC (UNCHANGED) ---
  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        ForgetPasswordRequested(email: _emailController.text.trim()),
      );
    }
  }

  // --- UI AND STYLING (UPDATED) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // UPDATED
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ForgetPasswordSent) {
            context.go('/otppage', extra: _emailController.text.trim());
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: kPrimaryTextColor,
                          ), // UPDATED
                          onPressed: () => context.go('/signin'),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Title
                      Text(
                        _isAmharic ? "የይለፍ ቃል ረስተው?" : "Forgot Password?",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: kPrimaryTextColor, // UPDATED
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isAmharic
                            ? "እባክዎን የኢሜል አድራሻዎን ያስገቡ።"
                            : "Enter your email to receive a reset code.", // UPDATED text for clarity
                        style: const TextStyle(
                          fontSize: 16,
                          color: kSecondaryTextColor, // UPDATED
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Email Input
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Email is required';
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value))
                            return 'Invalid email format';
                          return null;
                        },
                        decoration: _inputDecoration(
                          // UPDATED
                          _isAmharic ? "የኢሜል አድራሻ" : "Email",
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Continue Button
                      ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: _primaryButtonStyle(), // UPDATED
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                _isAmharic ? "ቀጥል" : "Continue",
                                style: const TextStyle(
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
          },
        ),
      ),
    );
  }

  // --- HELPER STYLING METHODS (UPDATED) ---

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: kSecondaryTextColor),
    prefixIcon: const Icon(Icons.email_outlined, color: kButtonColor),
    filled: true,
    fillColor: kCardBackgroundColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kButtonColor, width: 2),
    ),
  );

  ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: kButtonColor,
    foregroundColor: Colors.white,
    elevation: 4,
    shadowColor: kShadowColor,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  );
}
