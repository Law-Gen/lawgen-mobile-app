class Profile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String birthDate;
  final String gender;

  final String? profilePictureUrl;
  final String? subscriptionStatus;
  final String? role;
  final String? languagePreference;

  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.birthDate,
    required this.gender,
    this.profilePictureUrl,
    this.subscriptionStatus,
    this.role,
    this.languagePreference,
  });
}
