import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  //bool _isAmharic = false;

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/signup');
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/forgotPassword');
  }

  void _navigateBack() {
    Navigator.pushNamed(context, '/chat');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      fillColor: const Color(0xFFF8F4F0),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is Authenticated) {
              Navigator.pushReplacementNamed(context, '/chat');
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Row: Back button left, Language toggle & Logo right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _navigateBack,
                      ),
                      SvgPicture.asset(
                        'assets/logo/logo.svg',
                        height: 32,
                        width: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 48.0),

                  // Welcome Message
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48.0),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) return 'Invalid email';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: const Color(0xFFFFFFFF),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD8DADC)),
                      ),

                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      fillColor: const Color(0xFFFFFFFF),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFFD8DADC),
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _navigateToForgotPassword,
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Sign In Button
                  ElevatedButton(
                    onPressed: _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A1D37),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFD8DADC)),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // OR Separator
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // Google Sign-In
                  OutlinedButton(
                    onPressed: () {
                      print('Sign In with Google pressed');
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFD8DADC)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo/google.jpg',
                          height: 24,
                          width: 24,
                        ),
                        const Text('Continue with Google'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Sign Up Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: _navigateToSignUp,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
