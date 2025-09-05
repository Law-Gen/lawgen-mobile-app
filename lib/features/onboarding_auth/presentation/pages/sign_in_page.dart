import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
// Import the necessary packages
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pkce/pkce.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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

  // --- Logic for Email/Password Sign-In ---
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

  // --- Logic for Google Sign-In (UPDATED FOR NEW PACKAGE VERSIONS) ---
  Future<void> _handleGoogleSignIn() async {
    try {
      final pkcePair = PkcePair.generate();

      // FIX 1: The GoogleSignIn constructor is gone. You now configure the instance directly.
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // Using your real Server Client ID
        serverClientId: '329268316396-v9d06obror1h6i1199i6ap2703nhdjk3.apps.googleusercontent.com',
        scopes: <String>['email', 'profile'],
      );

      // FIX 2: The .signIn() method still works the same way.
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('Google sign in canceled by user.');
        return;
      }

      // FIX 3: '.serverAuthCode' is now on the 'authentication' object.
      final auth = await googleUser.authentication;
      final serverAuthCode = auth.serverAuthCode;

      if (serverAuthCode == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get authorization code from Google.')),
          );
        }
        return;
      }

      if (mounted) {
        context.read<AuthBloc>().add(
          GoogleSignInRequested(
            authCode: serverAuthCode,
            // FIX 4: The property is now 'codeVerifier', not 'verifier'.
            codeVerifier: pkcePair.codeVerifier,
          ),
        );
      }
    } catch (error) {
      print('Error during Google Sign-In: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred during Google Sign-In: $error')),
        );
      }
    }
  }
  
  // --- Navigation Methods ---
  void _navigateToSignUp() => context.go('/signup');
  void _navigateToForgotPassword() => context.go('/forgotpassword');
  void _navigateBack() => context.go('/profile');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.go('/chat');
            } else if (state is AuthError) {
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
              if (state is AuthLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(icon: const Icon(Icons.arrow_back), onPressed: _navigateBack),
                          SvgPicture.asset('assets/logo/logo.svg', height: 32, width: 32),
                        ],
                      ),
                      const SizedBox(height: 48.0),
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
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
                          if (!emailRegex.hasMatch(value)) return 'Invalid email';
                          return null;
                        },
                        decoration: _inputDecoration('Email', Icons.email_outlined),
                      ),
                      const SizedBox(height: 16.0),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        decoration: _passwordDecoration(),
                      ),
                      const SizedBox(height: 8.0),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _navigateToForgotPassword,
                          child: const Text("Forgot Password?", style: TextStyle(color: Colors.blueAccent)),
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Sign In Button
                      ElevatedButton(
                        onPressed: _handleEmailSignIn,
                        style: _primaryButtonStyle(),
                        child: const Text('Sign In', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      const SizedBox(height: 24.0),
                      
                      const Row(children: [ Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('OR')), Expanded(child: Divider())]),
                      const SizedBox(height: 24.0),

                      // Google Sign In Button
                      OutlinedButton(
                        onPressed: _handleGoogleSignIn,
                        style: _secondaryButtonStyle(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/logo/google.jpg', height: 24, width: 24),
                            const SizedBox(width: 12),
                            const Text('Continue with Google', style: TextStyle(color: Colors.black87, fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          TextButton(
                            onPressed: _navigateToSignUp,
                            child: const Text('Sign Up', style: TextStyle(color: Colors.blueAccent)),
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

  // Helper styling methods
  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  InputDecoration _passwordDecoration() => InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      );

  ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A1D37),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  ButtonStyle _secondaryButtonStyle() => OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFFD8DADC)),
      );
}