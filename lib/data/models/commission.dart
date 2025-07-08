import 'package:cloud_firestore/cloud_firestore.dart';

class CommissionModel {
  final String commissionId;
  final List<String> orderIds; // Danh sách các orderId thuộc đợt trả hoa hồng này
  final String storeId;
  final String storeName;
  final double orderAmount; // Tổng tiền của các đơn
  final double commissionAmount; // Tổng hoa hồng phải trả
  final String status; // 'pending', 'paid', 'overdue', 'cancelled'
  final DateTime orderDate; // Ngày của đơn mới nhất hoặc ngày tạo commission
  final DateTime? paidDate;
  final DateTime dueDate;
  final String? paymentProof;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommissionModel({
    required this.commissionId,
    required this.orderIds,
    required this.storeId,
    required this.storeName,
    required this.orderAmount,
    required this.commissionAmount,
    this.status = 'pending',
    required this.orderDate,
    this.paidDate,
    required this.dueDate,
    this.paymentProof,
    this.adminNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommissionModel.fromJson(Map<String, dynamic> json) {
    return CommissionModel(
      commissionId: json['commissionId'] ?? '',
      orderIds: List<String>.from(json['orderIds'] ?? []),
      storeId: json['storeId'] ?? '',
      storeName: json['storeName'] ?? '',
      orderAmount: (json['orderAmount'] ?? 0).toDouble(),
      commissionAmount: (json['commissionAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      orderDate: json['orderDate'] != null ? (json['orderDate'] as Timestamp).toDate() : DateTime.now(),
      paidDate: json['paidDate'] != null ? (json['paidDate'] as Timestamp).toDate() : null,
      dueDate:
          json['dueDate'] != null
              ? (json['dueDate'] as Timestamp).toDate()
              : DateTime.now().add(const Duration(days: 7)),
      paymentProof: json['paymentProof'],
      adminNote: json['adminNote'],
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'commissionId': commissionId,
    'orderIds': orderIds,
    'storeId': storeId,
    'storeName': storeName,
    'orderAmount': orderAmount,
    'commissionAmount': commissionAmount,
    'status': status,
    'orderDate': orderDate,
    'paidDate': paidDate,
    'dueDate': dueDate,
    'paymentProof': paymentProof,
    'adminNote': adminNote,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  CommissionModel copyWith({
    String? commissionId,
    List<String>? orderIds,
    String? storeId,
    String? storeName,
    double? orderAmount,
    double? commissionAmount,
    String? status,
    DateTime? orderDate,
    DateTime? paidDate,
    DateTime? dueDate,
    String? paymentProof,
    String? adminNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommissionModel(
      commissionId: commissionId ?? this.commissionId,
      orderIds: orderIds ?? this.orderIds,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      orderAmount: orderAmount ?? this.orderAmount,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      paidDate: paidDate ?? this.paidDate,
      dueDate: dueDate ?? this.dueDate,
      paymentProof: paymentProof ?? this.paymentProof,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isOverdue => DateTime.now().isAfter(dueDate) && status == 'pending';
  bool get isDueToday => DateTime.now().difference(dueDate).inDays == 0;
  bool get isDueSoon => DateTime.now().difference(dueDate).inDays <= 1;
  int get daysOverdue => DateTime.now().difference(dueDate).inDays;
  String get statusText {
    switch (status) {
      case 'pending':
        return isOverdue ? 'Quá hạn' : 'Chờ thanh toán';
      case 'paid':
        return 'Đã thanh toán';
      case 'overdue':
        return 'Quá hạn';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }
}
