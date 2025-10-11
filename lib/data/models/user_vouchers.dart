import 'package:cloud_firestore/cloud_firestore.dart';

class UserVoucherModel {
  final String id;
  final String code;
  final String userId;
  final String voucherId;
  final String discountType;
  final double discountValue;
  final double minOrder;
  final DateTime createdAt;
  final DateTime endDate;
  final DateTime? usedAt;
  final int count;
  final String status; // "available" | "used" | "expired"

  UserVoucherModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrder,
    required this.userId,
    required this.voucherId,
    required this.createdAt,
    required this.endDate,
    this.count = 1,
    this.usedAt,
    required this.status,
  });

  factory UserVoucherModel.fromJson(Map<String, dynamic> json) {
    return UserVoucherModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      userId: json['userId'] ?? '',
      discountType: json['discountType'] ?? 'fixed',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      minOrder: (json['minOrder'] ?? 0).toDouble(),
      voucherId: json['voucherId'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      count: (json['count'] ?? 1).toInt(),
      usedAt: json['usedAt'] != null ? (json['usedAt'] as Timestamp).toDate() : null,
      status: json['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'code': code,
        'discountType': discountType,
        'discountValue': discountValue,
        'minOrder': minOrder,
        'voucherId': voucherId,
        'createdAt': Timestamp.fromDate(createdAt),
        'endDate': Timestamp.fromDate(endDate),
        'count': count,
        'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
        'status': status,
      };

  UserVoucherModel copyWith({
    String? id,
    String? code,
    String? userId,
    String? voucherId,
    String? discountType,
    double? discountValue,
    double? minOrder,
    DateTime? createdAt,
    DateTime? endDate,
    DateTime? usedAt,
    int? count,
    String? status,
  }) {
    return UserVoucherModel(
      id: id ?? this.id,
      code: code ?? this.code,
      userId: userId ?? this.userId,
      voucherId: voucherId ?? this.voucherId,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrder: minOrder ?? this.minOrder,
      createdAt: createdAt ?? this.createdAt,
      endDate: endDate ?? this.endDate,
      usedAt: usedAt ?? this.usedAt,
      count: count ?? this.count,
      status: status ?? this.status,
    );
  }
}
