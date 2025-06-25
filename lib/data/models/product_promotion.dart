import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPromotionModel {
  final String id;
  final String storeId;
  final List<String> productIds;
  final double discountValue;
  final String discountType; // 'fixed' hoặc 'percent'
  final DateTime startDate;
  final DateTime endDate;
  final String? promotionId; // Gắn vào chiến dịch nếu có

  ProductPromotionModel({
    required this.id,
    required this.storeId,
    required this.productIds,
    required this.discountValue,
    required this.discountType,
    required this.startDate,
    required this.endDate,
    this.promotionId,
  });

  factory ProductPromotionModel.fromJson(Map<String, dynamic> json) {
    return ProductPromotionModel(
      id: json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      productIds: List<String>.from(json['productIds'] ?? []),
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      discountType: json['discountType'] ?? 'fixed',
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      promotionId: json['promotionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'productIds': productIds,
      'discountValue': discountValue,
      'discountType': discountType,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'promotionId': promotionId,
    };
  }

  ProductPromotionModel copyWith({
    String? id,
    String? storeId,
    List<String>? productIds,
    double? discountValue,
    String? discountType,
    DateTime? startDate,
    DateTime? endDate,
    String? promotionId,
  }) {
    return ProductPromotionModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      productIds: productIds ?? this.productIds,
      discountValue: discountValue ?? this.discountValue,
      discountType: discountType ?? this.discountType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      promotionId: promotionId ?? this.promotionId,
    );
  }

  bool get isValid {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && discountValue > 0;
  }

}
