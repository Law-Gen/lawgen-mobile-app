import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pkce/pkce.dart';

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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // --- LOGIC (UNCHANGED) ---
  void _signUp() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        SignUpRequested(
          full_name: fullNameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final pkcePair = PkcePair.generate();
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            '329268316396-v9d06obror1h6i1199i6ap2703nhdjk3.apps.googleusercontent.com',
        scopes: <String>['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final auth = await googleUser.authentication;
      final serverAuthCode = auth.serverAuthCode;

      if (serverAuthCode == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get authorization code from Google.'),
          ),
        );
        return;
      }

      if (mounted) {
        context.read<AuthBloc>().add(
          GoogleSignInRequested(
            authCode: serverAuthCode,
            codeVerifier: pkcePair.codeVerifier,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred during Google Sign-In: $error'),
          ),
        );
      }
    }
  }

  void _navigateToSignIn() {
    context.go('/signin');
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
          } else if (state is SignUpEmailSent) {
            context.go('/signin');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Sign up successful! Please check your email to verify.',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is Authenticated) {
            context.go('/chat');
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 4.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: kPrimaryTextColor,
                          ), // UPDATED
                          onPressed: _navigateToSignIn,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Create an Account', // UPDATED
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: kPrimaryTextColor, // UPDATED
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start your journey with us', // UPDATED
                        style: TextStyle(
                          color: kSecondaryTextColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Form Fields
                      TextFormField(
                        controller: fullNameController,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                        decoration: _inputDecoration(
                          'Full Name',
                          Icons.person_outline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value))
                            return 'Invalid email';
                          return null;
                        },
                        decoration: _inputDecoration(
                          'Email',
                          Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (value.length < 8) return 'Minimum 8 characters';
                          return null;
                        },
                        decoration: _passwordDecoration('Password'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (value != passwordController.text)
                            return 'Passwords must match';
                          return null;
                        },
                        decoration: _passwordDecoration('Confirm Password'),
                      ),
                      const SizedBox(height: 24),

                      // Sign Up Button
                      ElevatedButton(
                        onPressed: isLoading ? null : _signUp,
                        style: _primaryButtonStyle(), // UPDATED
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),

                      // OR Separator
                      Row(
                        children: const [
                          Expanded(
                            child: Divider(color: kShadowColor),
                          ), // UPDATED
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'OR',
                              style: TextStyle(color: kSecondaryTextColor),
                            ), // UPDATED
                          ),
                          Expanded(
                            child: Divider(color: kShadowColor),
                          ), // UPDATED
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Google Button
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : _handleGoogleSignIn,
                        style: _secondaryButtonStyle(), // UPDATED
                        icon: Image.asset(
                          'assets/logo/google.jpg',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 16,
                            color: kPrimaryTextColor, // UPDATED
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Already have account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: kPrimaryTextColor,
                            ), // UPDATED
                          ),
                          TextButton(
                            onPressed: isLoading ? null : _navigateToSignIn,
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: kButtonColor, // UPDATED
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kSecondaryTextColor),
        prefixIcon: Icon(icon, color: kButtonColor),
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

  InputDecoration _passwordDecoration(String label) =>
      _inputDecoration(label, Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: kSecondaryTextColor,
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
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

  ButtonStyle _secondaryButtonStyle() => OutlinedButton.styleFrom(
    backgroundColor: kCardBackgroundColor,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    side: const BorderSide(color: kShadowColor),
  );
}
