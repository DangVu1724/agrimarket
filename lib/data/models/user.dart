import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String? role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'buyer',
       createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'name': name,
        'phone': phone,
        'role': role,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      };
}
