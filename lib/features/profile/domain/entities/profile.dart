class Profile {
  final String id;
  final String full_name;
  final String email;
  final String? gender;
  final String? birthDate;
  final String? profilePictureUrl;
  final String? languagePreference;

  Profile({
    required this.id,
    required this.full_name,
    required this.email,
    this.gender,
    this.birthDate,
    this.profilePictureUrl,
    this.languagePreference,
  });

  // --- THIS IS THE CORRECTED FACTORY METHOD ---
  factory Profile.fromJson(Map<String, dynamic> json) {
    // 1. First, get the object inside the top-level "data" key.
    //    If "data" doesn't exist, fall back to using the original json map.
    final data = json['data'] ?? json;

    // 2. Now, from within that 'data' object, get the user details.
    //    Sometimes the details are nested further in 'user', sometimes not. This handles both.
    final userData = data['user'] ?? data;
    final profileData = userData['profile'] ?? {};

    // Handles the specific date format from your backend
    String formattedBirthDate = profileData['birth_date'] ?? '';
    if (formattedBirthDate.startsWith('0001-01-01')) {
      formattedBirthDate = ''; // Treat the default zero-value date as empty
    } else {
      formattedBirthDate = formattedBirthDate.split('T').first;
    }

    return Profile(
      id: userData['id'] ?? '',
      full_name: userData['full_name'] ?? '',
      email: userData['email'] ?? '',
      gender: profileData['gender'],
      birthDate: formattedBirthDate,
      profilePictureUrl: profileData['profile_picture_url'],
      languagePreference: profileData['language_preference'],
    );
  }
}
