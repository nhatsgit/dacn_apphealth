class UserInfoModel {
  final String fullName;
  final String address;
  final String avatar;
  final String phoneNumber;
  final String email;
  final String userName;

  UserInfoModel({
    required this.fullName,
    required this.address,
    required this.avatar,
    required this.phoneNumber,
    required this.email,
    required this.userName,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      fullName: json['fullName'],
      address: json['address'],
      avatar: json['avatar'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      userName: json['userName'],
    );
  }
}
