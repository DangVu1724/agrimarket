import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String userId;
  final String userName;
  final String role; // 'buyer', 'store'
  final String content;
  final DateTime createdAt;
  final String commentId;

  Comment({
    required this.userId,
    required this.userName,
    required this.role,
    required this.content,
    required this.createdAt,
    required this.commentId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(

        userId: json['userId'] ?? '',
        userName: json['userName'] ?? '',
        role: json['role'] ?? 'buyer',
        content: json['content'] ?? '',
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        commentId: json['commentId'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'role': role,
        'content': content,
        'createdAt': Timestamp.fromDate(createdAt),
        
      };
}
