import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawgen/app/dependency_injection.dart';
import 'package:lawgen/features/onboarding_auth/presentation/bloc/auth_bloc.dart';
import 'package:lawgen/features/onboarding_auth/presentation/bloc/auth_event.dart';

import '../../domain/entities/profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>()..add(LoadProfile()),
        ),
        BlocProvider.value(value: sl<AuthBloc>()),
      ],
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  // State variables for dropdowns
  String? _selectedGender;
  String? _selectedLanguage;

  bool _isEditing = false;
  File? _pickedImageFile;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = File(pickedFile.path);
      });
    }
  }

  void _saveChanges(Profile currentProfile) {
    // Map the display values back to the codes the backend expects
    String? genderCode;
    if (_selectedGender == 'Male') genderCode = 'M';
    if (_selectedGender == 'Female') genderCode = 'F';

    String? langCode;
    if (_selectedLanguage == 'English') langCode = 'En';
    if (_selectedLanguage == 'Amharic') langCode = 'Am';

    final updatedProfile = Profile(
      id: currentProfile.id,
      full_name: fullNameController.text,
      email: currentProfile.email,
      gender: genderCode,
      birthDate: birthDateController.text,
      languagePreference: langCode,
      profilePictureUrl: currentProfile.profilePictureUrl,
    );
    context.read<ProfileBloc>().add(
      SaveProfile(updatedProfile, _pickedImageFile),
    );
    setState(() => _isEditing = false);
  }

  void _logout() {
    context.go('/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && state is! ProfileUpdating) {
            if (_isEditing) {
              setState(() {
                _isEditing = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Profile updated successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            }
            final profile = state.profile;
            fullNameController.text = profile.full_name;
            emailController.text = profile.email;
            birthDateController.text = profile.birthDate ?? '';
            setState(() {
              _pickedImageFile = null;
              // Map codes from the server to display values for the UI
              if (profile.gender == 'F') _selectedGender = 'Female';
              if (profile.gender == 'M') _selectedGender = 'Male';

              if (profile.languagePreference == 'En')
                _selectedLanguage = 'English';
              if (profile.languagePreference == 'Am')
                _selectedLanguage = 'Amharic';
            });
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is! ProfileLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = state.profile;
          final isSaving = state is ProfileUpdating;

          return SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.go('/chat'),
                      ),
                      SvgPicture.asset('assets/logo/logo.svg', height: 32),
                    ],
                  ),
                ),
                // Profile Picture
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _pickedImageFile != null
                          ? FileImage(_pickedImageFile!)
                          : (profile.profilePictureUrl != null &&
                                    profile.profilePictureUrl!.isNotEmpty
                                ? NetworkImage(profile.profilePictureUrl!)
                                : const AssetImage(
                                        "assets/images/profile_placeholder.png",
                                      )
                                      as ImageProvider),
                    ),
                    if (_isEditing)
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF0A1D37),
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  profile.full_name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Form Fields
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _profileItem(
                        label: "Full Name",
                        controller: fullNameController,
                        icon: Icons.person_outline,
                      ),
                      _profileItem(
                        label: "Email",
                        controller: emailController,
                        icon: Icons.email_outlined,
                        editable: false,
                      ),
                      _genderDropdown(),
                      _profileItem(
                        label: "Birthdate",
                        controller: birthDateController,
                        icon: Icons.calendar_today_outlined,
                        onTap: _isEditing
                            ? () => _selectBirthDate(context)
                            : null,
                      ),
                      _languageDropdown(),
                    ],
                  ),
                ),
                // Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isSaving
                              ? null
                              : (_isEditing
                                    ? () => _saveChanges(profile)
                                    : () => setState(() => _isEditing = true)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A1D37),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: isSaving
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2.0),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Icon(
                                  _isEditing
                                      ? Icons.save_alt_outlined
                                      : Icons.edit_outlined,
                                ),
                          label: Text(
                            _isEditing ? "Save Changes" : "Edit Profile",
                          ),
                        ),
                      ),
                      if (_isEditing) ...[
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            context.read<ProfileBloc>().add(LoadProfile());
                            setState(() => _isEditing = false);
                          },
                          icon: const Icon(Icons.cancel_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => context.go('/subscription'),
                        icon: const Icon(
                          Icons.workspace_premium_outlined,
                          color: Colors.amber,
                        ),
                        label: const Text(
                          "Premium",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HELPER METHODS ---

  Future<void> _selectBirthDate(BuildContext context) async {
    DateTime initialDate =
        DateTime.tryParse(birthDateController.text) ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0A1D37)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Widget _profileItem({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool editable = true,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing && editable,
        readOnly: onTap != null,
        onTap: onTap,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0A1D37),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          fillColor: _isEditing && editable
              ? Colors.white
              : Colors.grey.shade100,
          filled: true,
          prefixIcon: Icon(icon, color: const Color(0xFF0A1D37)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0A1D37), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        items: ['Male', 'Female']
            .map(
              (String value) =>
                  DropdownMenuItem<String>(value: value, child: Text(value)),
            )
            .toList(),
        onChanged: _isEditing
            ? (String? newValue) => setState(() => _selectedGender = newValue)
            : null,
        decoration: InputDecoration(
          labelText: 'Gender',
          prefixIcon: const Icon(Icons.wc_outlined, color: Color(0xFF0A1D37)),
          fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
    );
  }

  Widget _languageDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedLanguage,
        items: ['English', 'Amharic']
            .map(
              (String value) =>
                  DropdownMenuItem<String>(value: value, child: Text(value)),
            )
            .toList(),
        onChanged: _isEditing
            ? (String? newValue) => setState(() => _selectedLanguage = newValue)
            : null,
        decoration: InputDecoration(
          labelText: 'Language',
          prefixIcon: const Icon(
            Icons.language_outlined,
            color: Color(0xFF0A1D37),
          ),
          fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
    );
  }
}
