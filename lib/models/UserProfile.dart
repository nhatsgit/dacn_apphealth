class UserProfile {
  final String id;
  final String fullName;
  final String? gender;
  final String? dateOfBirth;
  final double? height;
  final double? latestWeight;
  final double? bmi;

  UserProfile({
    required this.id,
    required this.fullName,
    this.gender,
    this.dateOfBirth,
    this.height,
    this.latestWeight,
    this.bmi,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['fullName'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      height: (json['height'] as num?)?.toDouble(),
      latestWeight: (json['latestWeight'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
    );
  }
}
