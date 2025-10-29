import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionCampaignModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final List<String> stores;
  final String? discountId;
  final DateTime endTime;
  final bool isActive;
  final String type; 

  PromotionCampaignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.stores,
    required this.endTime,
    required this.isActive,
    required this.type,
    this.discountId,
  });

  factory PromotionCampaignModel.fromJson(Map<String, dynamic> json) {
    return PromotionCampaignModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: (json['startTime'] as Timestamp).toDate(),
      stores: List<String>.from(json['stores'] ?? []),
      endTime: (json['endTime'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? false,
      type: json['type'] ?? 'system',
      discountId: json['discountId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime,
      'stores': stores,
      'endTime': endTime,
      'isActive': isActive,
      'type': type,
      'discountId': discountId,
    };
  }

  
}
