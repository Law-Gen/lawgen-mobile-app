import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'sign_in_page.dart';
import 'success_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String resetToken;

  const ResetPasswordPage({super.key, required this.resetToken});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  void _onReset() {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 8 characters long"),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    // Dispatch API request via AuthBloc
    context.read<AuthBloc>().add(
      ResetPasswordRequested(token: widget.resetToken, newPassword: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is PasswordResetSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SuccessResetPage()),
              );
            } else if (state is AuthError) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            _isLoading = state is AuthLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignInPage()),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  SvgPicture.asset(
                    'assets/logo/logo.svg',
                    height: 32,
                    width: 32,
                    color: Colors.black,
                  ),

                  const Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Enter your new password and confirm it.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 32),

                  // New password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      filled: true,
                      fillColor: const Color(0xFFFFFFFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFD8DADC)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm password
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      filled: true,
                      fillColor: const Color(0xFFFFFFFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFD8DADC)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Reset button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A1D37),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Reset Password",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
