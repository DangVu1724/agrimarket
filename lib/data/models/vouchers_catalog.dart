import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String code;
  final String description;
  final int pointsRequired;
  final String discountType; // "percentage" | "fixed"
  final double discountValue;
  final double minOrderValue;
  final int validDays;
  final int usageLimit;
  final int usedCount;
  final String createdBy;
  final bool isActive;

  VoucherModel({
    required this.id,
    required this.code,
    required this.pointsRequired,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.validDays,
    required this.usageLimit,
    required this.usedCount,
    required this.createdBy,
    required this.isActive,
    
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      discountType: json['discountType'] ?? 'fixed',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      minOrderValue: (json['minOrderValue'] ?? 0).toDouble(),
      validDays: (json['validDays'] ?? 0).toInt(),
      usageLimit: json['usageLimit'] ?? 0,
      usedCount: json['usedCount'] ?? 0,
      createdBy: json['createdBy'] ?? '',
      isActive: json['isActive'] ?? true,
      pointsRequired: json['pointsRequired'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'description': description,
        'discountType': discountType,
        'discountValue': discountValue,
        'minOrderValue': minOrderValue,
        'validDays': validDays,
        'usageLimit': usageLimit,
        'usedCount': usedCount,
        'createdBy': createdBy,
        'isActive': isActive,
        'pointsRequired': pointsRequired,
      };
}
