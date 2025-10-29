import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String buyerUid;
  final String storeId;
  final String? storeName;
  final List<OrderItem> items;
  final String status;
  final String paymentMethod;
  final double totalPrice;
  final double? discountPrice;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String deliveryAddress;
  final String? discountCodeId;
  final bool? isPaid;
  final bool? isCommissionPaid;
  final DateTime? deliveredAt;
  final bool? isReviewed;
  final List<String>? reviewImages;
  final double? rating;
  final String? comment;
  final String? buyerName;
  final String? buyerPhone;

  OrderModel({
    required this.orderId,
    required this.buyerUid,
    required this.storeId,
    this.storeName,
    required this.items,
    required this.status,
    required this.totalPrice,
    required this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
    required this.deliveryAddress,
    this.discountCodeId,
    this.reviewImages,
    this.discountPrice,
    this.isPaid,
    this.isCommissionPaid,
    this.deliveredAt,
    this.isReviewed,
    this.rating,
    this.comment,
    this.buyerName,
    this.buyerPhone,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'],
      buyerUid: json['buyerUid'],
      storeId: json['storeId'],
      storeName: json['storeName'],
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      createdAt:
          json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? (json['updatedAt'] is Timestamp
                  ? (json['updatedAt'] as Timestamp).toDate()
                  : DateTime.parse(json['updatedAt'] as String))
              : null,
      deliveryAddress: json['deliveryAddress'],
      discountCodeId: json['discountCodeId'],
      discountPrice: json['discountPrice'] != null ? (json['discountPrice'] as num).toDouble() : null,
      isPaid: json['isPaid'] ?? false,
      isCommissionPaid: json['isCommissionPaid'] ?? false,
      deliveredAt:
          json['deliveredAt'] != null
              ? (json['deliveredAt'] is Timestamp
                  ? (json['deliveredAt'] as Timestamp).toDate()
                  : DateTime.parse(json['deliveredAt'] as String))
              : null,
      isReviewed: json['isReviewed'] ?? false,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      comment: json['comment'],
      buyerName: json['buyerName'],
      buyerPhone: json['buyerPhone'],
      reviewImages: (json['reviewImages'] != null) ? List<String>.from(json['reviewImages']) : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'buyerUid': buyerUid,
    'storeId': storeId,
    'storeName': storeName,
    'items': items.map((item) => item.toJson()).toList(),
    'status': status,
    'totalPrice': totalPrice,
    'paymentMethod': paymentMethod,
    'discountPrice': discountPrice,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    'deliveryAddress': deliveryAddress,
    'discountCodeId': discountCodeId,
    'isPaid': isPaid,
    'isCommissionPaid': isCommissionPaid,
    'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
    'isReviewed': isReviewed,
    'rating': rating,
    'comment': comment,
    'buyerName': buyerName,
    'buyerPhone': buyerPhone,
    'reviewImages': reviewImages ?? [],
  };
  OrderModel copyWith({
    String? orderId,
    String? buyerUid,
    String? buyerName,
    String? buyerPhone,
    String? storeId,
    String? storeName,
    List<OrderItem>? items,
    String? status,
    double? totalPrice,
    double? discountPrice,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deliveryAddress,
    String? discountCodeId,
    bool? isPaid,
    bool? isCommissionPaid,
    DateTime? deliveredAt,
    bool? isReviewed,
    double? rating,
    String? comment,
    List<String>? reviewImages,
  }) => OrderModel(
    orderId: orderId ?? this.orderId,
    buyerUid: buyerUid ?? this.buyerUid,
    buyerName: buyerName ?? this.buyerName,
    buyerPhone: buyerPhone ?? this.buyerPhone,
    storeId: storeId ?? this.storeId,
    storeName: storeName ?? this.storeName,
    items: items ?? this.items,
    status: status ?? this.status,
    totalPrice: totalPrice ?? this.totalPrice,
    discountPrice: discountPrice ?? this.discountPrice,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    discountCodeId: discountCodeId ?? this.discountCodeId,
    isPaid: isPaid ?? this.isPaid,
    isCommissionPaid: isCommissionPaid ?? this.isCommissionPaid,
    deliveredAt: deliveredAt ?? this.deliveredAt,
    isReviewed: isReviewed ?? this.isReviewed,
    rating: rating ?? this.rating,
    comment: comment ?? this.comment,
    reviewImages: reviewImages ?? this.reviewImages,
  );
}

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String unit;
  final double? promotionPrice;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.unit,
    this.promotionPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      name: json['name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      unit: json['unit'],
      promotionPrice: json['promotionPrice'] != null ? (json['promotionPrice'] as num).toDouble() : null,
    );
  }
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'quantity': quantity,
    'price': price,
    'unit': unit,
    'promotionPrice': promotionPrice,
  };
  OrderItem copyWith({
    String? productId,
    String? name,
    int? quantity,
    double? price,
    String? unit,
    double? promotionPrice,
  }) => OrderItem(
    productId: productId ?? this.productId,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    price: price ?? this.price,
    unit: unit ?? this.unit,
    promotionPrice: promotionPrice ?? this.promotionPrice,
  );
}
