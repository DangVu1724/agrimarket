import 'package:cloud_firestore/cloud_firestore.dart';

class DiscountCodeModel {
  final String id; 
  final String code;
  final String? storeId; // null nếu là mã toàn hệ thống
  final String creatorRole; // "admin" hoặc "seller"
  final String discountType; // "percent" hoặc "fixed"
  final double value;
  final double minOrder;
  final DateTime startDate;
  final DateTime expiredDate;
  final int limit;
  final int used;
  final String? promotionId; // gắn vào chương trình nào đó (nếu có)

  DiscountCodeModel({
    required this.id,
    required this.code,
    this.storeId,
    required this.creatorRole,
    required this.discountType,
    required this.value,
    required this.minOrder,
    required this.startDate,
    required this.expiredDate,
    required this.limit,
    required this.used,
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
      discountType: json['discountType'] ?? 'fixed',
      value: (json['value'] ?? 0).toDouble(),
      minOrder: (json['minOrder'] ?? 0).toDouble(),
      startDate: (json['startDate'] as Timestamp).toDate(),
      expiredDate: (json['expiredDate'] as Timestamp).toDate(),
      limit: json['limit'] ?? 0,
      used: json['used'] ?? 0,
      promotionId: json['promotionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'storeId': storeId,
      'creatorRole': creatorRole,
      'discountType': discountType,
      'value': value,
      'minOrder': minOrder,
      'startDate': startDate,
      'expiredDate': expiredDate,
      'limit': limit,
      'used': used,
      'promotionId': promotionId,
    };
  }

  DiscountCodeModel copyWith({
    String? id,
    String? code,
    String? storeId,
    String? creatorRole,
    String? discountType,
    double? value,
    double? minOrder,
    DateTime? startDate,
    DateTime? expiredDate,
    int? limit,
    int? used,
    String? promotionId,
  }) {
    return DiscountCodeModel(
      id: id ?? this.id,
      code: code ?? this.code,
      storeId: storeId ?? this.storeId,
      creatorRole: creatorRole ?? this.creatorRole,
      discountType: discountType ?? this.discountType,
      value: value ?? this.value,
      minOrder: minOrder ?? this.minOrder,
      startDate: startDate ?? this.startDate,
      expiredDate: expiredDate ?? this.expiredDate,
      limit: limit ?? this.limit,
      used: used ?? this.used,
      promotionId: promotionId ?? this.promotionId,
    );
  }
}
