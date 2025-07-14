// lib/data/models/cart.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cart {
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Cart({required this.userId, required this.items, required this.createdAt, this.updatedAt});

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'items': items.map((item) => item.toJson()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
  };

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    userId: json['userId'],
    items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
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
  );
}

class CartItem {
  final String productId;
  final String storeId;
  final RxInt quantity;
  final double priceAtAddition;
  final String productName;
  final String productImage;
  final String unit;
  final String storeName;
  final double? promotionPrice;
  bool? isOnSaleAtAddition;

  CartItem({
    required this.productId,
    required this.storeId,
    required int quantity,
    required this.priceAtAddition,
    required this.productName,
    required this.productImage,
    required this.storeName,
    this.promotionPrice,
    this.isOnSaleAtAddition,
    required this.unit,
  }) : quantity = quantity.obs;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'storeId': storeId,
    'quantity': quantity.value,
    'priceAtAddition': priceAtAddition,
    'productName': productName,
    'productImage': productImage,
    'storeName': storeName,
    'promotionPrice': promotionPrice,
    'isOnSaleAtAddition': isOnSaleAtAddition,
    'unit': unit,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productId: json['productId'],
    storeId: json['storeId'],
    quantity: json['quantity'] as int,
    priceAtAddition: json['priceAtAddition'].toDouble(),
    productName: json['productName'],
    productImage: json['productImage'],
    storeName: json['storeName'],
    promotionPrice: json['promotionPrice']?.toDouble(),
    isOnSaleAtAddition: json['isOnSaleAtAddition'] ?? false,
    unit: json['unit'],
  );
}
