import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionCampaignModel {
  final String id;
  final String title;
  final String description;
  final String bannerImage;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String type; // "system" hoặc "store_based"

  PromotionCampaignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.bannerImage,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.type,
  });

  factory PromotionCampaignModel.fromJson(Map<String, dynamic> json) {
    return PromotionCampaignModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      bannerImage: json['bannerImage'] ?? '',
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? false,
      type: json['type'] ?? 'system',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'bannerImage': bannerImage,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'type': type,
    };
  }
}
