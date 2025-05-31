class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String? role;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'buyer',
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'name': name,
        'phone': phone,
        'role': role,
      };
}
