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

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIC (UNCHANGED) ---
  void _handleEmailSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        SignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
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

  void _navigateToSignUp() => context.go('/signup');
  void _navigateToForgotPassword() => context.go('/forgotpassword');

  // --- UI AND STYLING (UPDATED) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // UPDATED
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48.0),
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: kPrimaryTextColor, // UPDATED
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Sign in to your account',
                        style: TextStyle(
                          color: kSecondaryTextColor, // UPDATED
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48.0),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
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

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                        decoration: _passwordDecoration(),
                      ),
                      const SizedBox(height: 8.0),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : _navigateToForgotPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: kButtonColor), // UPDATED
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Sign In Button
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleEmailSignIn,
                        style: _primaryButtonStyle(),
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
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 32.0),

                      const Row(
                        children: [
                          Expanded(
                            child: Divider(color: kShadowColor),
                          ), // UPDATED
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: kSecondaryTextColor,
                              ), // UPDATED
                            ),
                          ),
                          Expanded(
                            child: Divider(color: kShadowColor),
                          ), // UPDATED
                        ],
                      ),
                      const SizedBox(height: 32.0),

                      // Google Sign In Button
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : _handleGoogleSignIn,
                        style: _secondaryButtonStyle(),
                        icon: Image.asset(
                          'assets/logo/google.jpg',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(
                            color: kPrimaryTextColor, // UPDATED
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32.0),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: kPrimaryTextColor,
                            ), // UPDATED
                          ),
                          TextButton(
                            onPressed: isLoading ? null : _navigateToSignUp,
                            child: const Text(
                              'Sign Up',
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
              );
            },
          ),
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

  InputDecoration _passwordDecoration() =>
      _inputDecoration('Password', Icons.lock_outline).copyWith(
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
