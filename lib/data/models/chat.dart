import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> members; // buyerId và sellerId
  final String lastMessage;
  final DateTime? lastTimestamp;

  ChatModel({
    required this.chatId,
    required this.members,
    required this.lastMessage,
    required this.lastTimestamp,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json, String id) {
    return ChatModel(
      chatId: id,
      members: List<String>.from(json['members'] ?? []),
      lastMessage: json['lastMessage'] ?? '',
      lastTimestamp: (json['lastTimestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'members': members,
    'lastMessage': lastMessage,
    'lastTimestamp': lastTimestamp,
  };
}
