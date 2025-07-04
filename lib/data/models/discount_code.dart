import 'package:cloud_firestore/cloud_firestore.dart';

class DiscountCodeModel {
  final String id; 
  final String code;
  final String? storeId; // null nếu là mã toàn hệ thống
  final String creatorRole; // "admin" hoặc "seller"
  final String creatorId;
  final String discountType; // "percent" hoặc "fixed"
  final double value;
  final double minOrder;
  final DateTime startDate;
  final DateTime expiredDate;
  final int limit;
  final int used;
  final bool isActive;
  final String? promotionId; // gắn vào chương trình nào đó (nếu có)

  DiscountCodeModel({
    required this.id,
    required this.code,
    this.storeId,
    required this.creatorRole,
    required this.creatorId,
    required this.discountType,
    required this.value,
    required this.minOrder,
    required this.startDate,
    required this.expiredDate,
    required this.limit,
    required this.used,
    required this.isActive,
    this.promotionId,
  });

  bool get isOnSale {
    return DateTime.now().isBefore(expiredDate);
  }

  factory DiscountCodeModel.fromJson(Map<String, dynamic> json) {
    return DiscountCodeModel(
      id: json['id'] ?? '', 
      code: json['code'] ?? '',
      storeId: json['storeId'],
      creatorRole: json['creatorRole'] ?? 'seller',
      creatorId: json['creatorId'] ?? '',
      discountType: json['discountType'] ?? 'fixed',
      value: (json['value'] ?? 0).toDouble(),
      minOrder: (json['minOrder'] ?? 0).toDouble(),
      startDate: (json['startDate'] as Timestamp).toDate(),
      expiredDate: (json['expiredDate'] as Timestamp).toDate(),
      limit: json['limit'] ?? 0,
      used: json['used'] ?? 0,
      isActive: json['isActive'] ?? false,
      promotionId: json['promotionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'storeId': storeId,
      'creatorRole': creatorRole,
      'creatorId': creatorId,
      'discountType': discountType,
      'value': value,
      'minOrder': minOrder,
      'startDate': startDate,
      'expiredDate': expiredDate,
      'limit': limit,
      'used': used,
      'isActive': isActive,
      'promotionId': promotionId,
    };
  }

  DiscountCodeModel copyWith({
    String? id,
    String? code,
    String? storeId,
    String? creatorRole,
    String? creatorId,
    String? discountType,
    double? value,
    double? minOrder,
    DateTime? startDate,
    DateTime? expiredDate,
    int? limit,
    int? used,
    bool? isActive,
    String? promotionId,
  }) {
    return DiscountCodeModel(
      id: id ?? this.id,
      code: code ?? this.code,
      storeId: storeId ?? this.storeId,
      creatorRole: creatorRole ?? this.creatorRole,
      creatorId: creatorId ?? this.creatorId,
      discountType: discountType ?? this.discountType,
      value: value ?? this.value,
      minOrder: minOrder ?? this.minOrder,
      startDate: startDate ?? this.startDate,
      expiredDate: expiredDate ?? this.expiredDate,
      limit: limit ?? this.limit,
      used: used ?? this.used,
      isActive: isActive ?? this.isActive,
      promotionId: promotionId ?? this.promotionId,
    );
  }
}
