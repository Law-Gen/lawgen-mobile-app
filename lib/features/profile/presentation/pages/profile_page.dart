import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/edit_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecases.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repositoryimpl.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
  create: (_) {

    final remoteDataSource = ProfileRemoteDataSourceImpl(client: http.Client());

    final repository = ProfileRepositoryImpl(remoteDataSource: remoteDataSource);

    final getProfileUseCase = GetProfileUseCase(repository);
    final updateProfileUseCase = UpdateProfileUseCase(repository);

    // Provide the Bloc
    return ProfileBloc(
      getProfile: getProfileUseCase,
      updateProfile: updateProfileUseCase,
    )..add(LoadProfile());
  },
),

        // Add other Blocs here if needed
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
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  bool _isEditing = false;
  File? _profileImage;
  String _firstName = "";
  String? _uploadedProfileUrl;
  Profile? _currentProfile;

  Future<void> _selectBirthDate(BuildContext context) async {
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

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture selected")),
      );

      try {
        _uploadedProfileUrl = await _uploadProfilePicture(_profileImage!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture uploaded successfully")),
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload profile picture")),
        );
      }
    }
  }

  Future<String> _uploadProfilePicture(File file) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("https://your-backend.com/users/upload-profile-picture"),
    );
    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return respStr;
    } else {
      throw Exception("Failed to upload image");
    }
  }

  void _saveChanges() {
    if (_currentProfile == null) return;

    final updatedProfile = Profile(
      id: _currentProfile!.id,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      gender: genderController.text,
      birthDate: birthDateController.text,
      profilePictureUrl: _uploadedProfileUrl ?? _currentProfile!.profilePictureUrl ?? "",
    );

    context.read<ProfileBloc>().add(SaveProfile(updatedProfile));

    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  void _navigateToSubscription() => context.go('/subscription');
  void _navigateToChat() => context.go('/chat');
  void _logout() => context.go('/signin');

  Widget _profileItem({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool editable = true,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6C757D),
          ),
          fillColor: const Color(0xFFF5F7FA),
          filled: true,
          prefixIcon: Icon(icon, color: const Color(0xFF0A1D37)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD8DADC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD8DADC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0A1D37), width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _currentProfile = state.profile;

          firstNameController.text = state.profile.firstName;
          lastNameController.text = state.profile.lastName;
          emailController.text = state.profile.email;
          genderController.text = state.profile.gender;
          birthDateController.text = state.profile.birthDate;
          _firstName = state.profile.firstName;

          if (state.profile.profilePictureUrl != null &&
              state.profile.profilePictureUrl!.isNotEmpty) {
            _profileImage = null;
            _uploadedProfileUrl = state.profile.profilePictureUrl;
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back), onPressed: _navigateToChat),
                    SvgPicture.asset('assets/logo/logo.svg', height: 32, width: 32),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Profile picture
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (_uploadedProfileUrl != null
                            ? NetworkImage(_uploadedProfileUrl!)
                            : const AssetImage("assets/images/profile_placeholder.png") as ImageProvider),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Hello, $_firstName",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _profileItem(label: "First Name", controller: firstNameController, icon: Icons.person),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _profileItem(label: "Last Name", controller: lastNameController, icon: Icons.person_outline),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _profileItem(label: "Email", controller: emailController, icon: Icons.email, editable: false),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _profileItem(label: "Gender", controller: genderController, icon: Icons.wc_outlined),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _profileItem(
                        label: "Birthdate",
                        controller: birthDateController,
                        icon: Icons.calendar_today,
                        editable: true,
                        onTap: _isEditing ? () => _selectBirthDate(context) : null,
                      ),
                    ),
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
                        onPressed: _isEditing ? _saveChanges : _toggleEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A1D37),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(_isEditing ? Icons.save : Icons.edit),
                        label: Text(_isEditing ? "Save" : "Edit", style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _navigateToSubscription,
                      icon: const Icon(Icons.workspace_premium, color: Colors.blue),
                      label: const Text("Premium", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    TextButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.blue),
                      label: const Text("Logout", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
