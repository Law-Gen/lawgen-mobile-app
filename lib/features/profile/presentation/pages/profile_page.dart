import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../app/dependency_injection.dart';
import '../../../onboarding_auth/presentation/bloc/auth_bloc.dart';
import '../../../onboarding_auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

// -- Design Constants --
const Color kBackgroundColor = Color(0xFFFFF8F6);
const Color kPrimaryTextColor = Color(0xFF4A4A4A);
const Color kSecondaryTextColor = Color(0xFF7A7A7A);
const Color kCardBackgroundColor = Colors.white;
const Color kButtonColor = Color(0xFF8B572A);
const Color kShadowColor = Color(0xFFD3C1B3);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => sl<ProfileBloc>()..add(LoadProfile()),
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
      setState(() => _pickedImageFile = File(pickedFile.path));
    }
  }

  void _saveChanges(Profile currentProfile) {
    String? genderCode;
    if (_selectedGender == 'Male') genderCode = 'M';
    if (_selectedGender == 'Female') genderCode = 'F';

    String? langCode;
    if (_selectedLanguage == 'English') langCode = 'En';
    if (_selectedLanguage == 'Amharic') langCode = 'Am';

    final updatedProfile = Profile(
      id: currentProfile.id,
      full_name: fullNameController.text.trim(),
      email: currentProfile.email,
      gender: genderCode,
      birthDate: birthDateController.text,
      languagePreference: langCode,
      profilePictureUrl: currentProfile.profilePictureUrl,
    );
    context.read<ProfileBloc>().add(
      SaveProfile(updatedProfile, _pickedImageFile),
    );
  }

  // UPDATED: Now closes the bottom sheet before logging out.
  void _logout() {
    // Ensure the bottom sheet is closed before dispatching the event
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    context.read<AuthBloc>().add(LogoutRequested());
  }

  void _populateFields(Profile profile) {
    fullNameController.text = profile.full_name;
    emailController.text = profile.email;
    birthDateController.text = profile.birthDate ?? '';

    String? displayGender;
    if (profile.gender == 'M') displayGender = 'Male';
    if (profile.gender == 'F') displayGender = 'Female';

    String? displayLanguage;
    if (profile.languagePreference == 'En') displayLanguage = 'English';
    if (profile.languagePreference == 'Am') displayLanguage = 'Amharic';

    setState(() {
      _pickedImageFile = null;
      _selectedGender = displayGender;
      _selectedLanguage = displayLanguage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            _populateFields(state.profile);
            setState(() => _isEditing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile updated successfully!"),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileLoaded) {
            _populateFields(state.profile);
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
          if (state is ProfileInitial || state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: kButtonColor),
            );
          }

          if (state is ProfileLoaded) {
            final profile = state.profile;
            final isSaving = state is ProfileUpdating;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 12.0,
                ),
                child: Column(
                  children: [
                    _buildTopBar(context),
                    _buildProfilePicture(profile),
                    const SizedBox(height: 12),
                    Text(
                      profile.full_name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: kSecondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(child: _buildForm(context)),
                    _buildActionButtons(context, profile, isSaving),
                    // _buildFooterButtons(context),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text("Could not load profile."));
        },
      ),
    );
  }

  // --- NEW METHOD ---
  // This function builds and displays the modern modal bottom sheet.
  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: kShadowColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 24),
              // The styled Logout Button
              ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Logout",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              // A cancel button to dismiss the sheet
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: kSecondaryTextColor, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- UPDATED METHOD ---
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: kPrimaryTextColor),
            onPressed: () => context.go('/chat'),
          ),
          const Text(
            "Profile",
            style: TextStyle(
              color: kPrimaryTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: kPrimaryTextColor),
            // This now triggers the bottom sheet
            onPressed: () => _showOptionsBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(Profile profile) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: kShadowColor.withOpacity(0.5),
          backgroundImage: _pickedImageFile != null
              ? FileImage(_pickedImageFile!)
              : (profile.profilePictureUrl != null &&
                        profile.profilePictureUrl!.isNotEmpty
                    ? NetworkImage(profile.profilePictureUrl!)
                    : const AssetImage("assets/images/profile_placeholder.png")
                          as ImageProvider),
        ),
        if (_isEditing)
          GestureDetector(
            onTap: _pickProfileImage,
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: kButtonColor,
              child: Icon(Icons.edit, size: 20, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          onTap: _isEditing ? () => _selectBirthDate(context) : null,
        ),
        _languageDropdown(),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Profile profile,
    bool isSaving,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
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
                backgroundColor: kButtonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: isSaving
                  ? Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _isEditing
                          ? Icons.save_alt_outlined
                          : Icons.edit_outlined,
                    ),
              label: Text(
                _isEditing ? "Save Changes" : "Edit Profile",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: kShadowColor.withOpacity(0.7),
                foregroundColor: kPrimaryTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- UPDATED METHOD ---
  Widget _buildFooterButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      // The Row now just contains the premium button
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Aligned to the left
        children: [
          TextButton.icon(
            onPressed: () {}, // Add navigation to premium page here
            icon: const Icon(
              Icons.workspace_premium_outlined,
              color: kButtonColor,
            ),
            label: const Text(
              "Premium",
              style: TextStyle(color: kPrimaryTextColor),
            ),
          ),
        ],
      ),
    );
  }

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
          colorScheme: const ColorScheme.light(primary: kButtonColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kSecondaryTextColor),
      fillColor: _isEditing ? kCardBackgroundColor : kBackgroundColor,
      filled: true,
      prefixIcon: Icon(icon, color: kButtonColor),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: _isEditing
            ? BorderSide(color: kShadowColor)
            : BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kButtonColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
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
          color: kPrimaryTextColor,
        ),
        decoration: _inputDecoration(label, icon),
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
        decoration: _inputDecoration('Gender', Icons.wc_outlined),
        style: const TextStyle(fontSize: 16, color: kPrimaryTextColor),
        iconEnabledColor: kButtonColor,
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
        decoration: _inputDecoration('Language', Icons.language_outlined),
        style: const TextStyle(fontSize: 16, color: kPrimaryTextColor),
        iconEnabledColor: kButtonColor,
      ),
    );
  }
}
