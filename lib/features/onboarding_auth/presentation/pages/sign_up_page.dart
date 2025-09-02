import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final birthDateController = TextEditingController();
  String? gender;
  bool _isPasswordVisible = false;
  //bool _isAmharic = false;

  void _selectBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignUpRequested(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          password: passwordController.text,
          birthDate: birthDateController.text,
          gender: gender!,
        ),
      );
    }
  }

  void _navigateToSignIn() {
    Navigator.pushNamed(context, '/signIn');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Back button left, Logo right, Language toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _navigateToSignIn,
                    ),
                    SvgPicture.asset(
                      'assets/logo/logo.svg',
                      height: 32,
                      width: 32,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Text(
                  'Welcome to LawGen',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // First Name
                TextFormField(
                  controller: firstNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  decoration: _inputDecoration(
                    'First Name',
                    Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: lastNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  decoration: _inputDecoration(
                    'Last Name',
                    Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: emailController,
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

                // Birthdate
                TextFormField(
                  controller: birthDateController,
                  readOnly: true,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  onTap: () => _selectBirthDate(context),
                  decoration: _inputDecoration(
                    'Birthdate',
                    Icons.cake_outlined,
                  ),
                ),
                const SizedBox(height: 16),

                // Password
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

                // Confirm Password
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
                const SizedBox(height: 16),

                // Gender
                Row(
                  children: [
                    const Text("Gender: "),
                    Expanded(
                      child: ListTile(
                        title: const Text('M'),
                        leading: Radio<String>(
                          value: 'M',
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() => gender = value);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('F'),
                        leading: Radio<String>(
                          value: 'F',
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() => gender = value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A1D37),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFD8DADC)),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),

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
                const SizedBox(height: 24),

                // Google Button
                OutlinedButton(
                  onPressed: () {},
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
                      const SizedBox(width: 8), // optional spacing
                      const Text(
                        'Continue with Google',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: _navigateToSignIn,
                      child: const Text(
                        'Sign In',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),

                // Bloc Listener for success/error
                BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthError) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    } else if (state is Authenticated) {
                      Navigator.pushReplacementNamed(context, '/chat');
                    }
                  },
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      fillColor: const Color(0xFFFFFFFF),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD8DADC)),
      ),
      prefixIcon: Icon(icon),
    );
  }

  InputDecoration _passwordDecoration(String label) {
    return InputDecoration(
      labelText: label,
      fillColor: const Color(0xFFFFFFFF),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD8DADC)),
      ),
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () {
          setState(() => _isPasswordVisible = !_isPasswordVisible);
        },
      ),
    );
  }
}
