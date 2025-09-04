class Profile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String birthDate;
  final String? profilePictureUrl;

  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.birthDate,
    this.profilePictureUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        gender: json['gender'],
        birthDate: json['birthDate'],
        profilePictureUrl: json['profilePictureUrl'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "gender": gender,
        "birthDate": birthDate,
        "profilePictureUrl": profilePictureUrl,
      };
}
