// lib/data/models/cart.dart
class Cart {
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Cart({
    required this.userId,
    required this.items,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'items': items.map((item) => item.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    userId: json['userId'],
    items:
        (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );
}

class CartItem {
  final String productId;
  final String storeId;
  final int quantity;
  final double priceAtAddition;
  final String productName;
  final String productImage;
  final String storeName;
  final double? promotionPrice;
  bool? isOnSaleAtAddition;

  CartItem({
    required this.productId,
    required this.storeId,
    required this.quantity,
    required this.priceAtAddition,
    required this.productName,
    required this.productImage,
    required this.storeName,
    this.promotionPrice,
    this.isOnSaleAtAddition

  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'storeId': storeId,
    'quantity': quantity,
    'priceAtAddition': priceAtAddition,
    'productName': productName,
    'productImage': productImage,
    'storeName': storeName,
    'promotionPrice': promotionPrice,
    'isOnSaleAtAddition': isOnSaleAtAddition,

  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productId: json['productId'],
    storeId: json['storeId'],
    quantity: json['quantity'],
    priceAtAddition: json['priceAtAddition'].toDouble(),
    productName: json['productName'],
    productImage: json['productImage'],
    storeName: json['storeName'],
    promotionPrice: json['promotionPrice']?.toDouble(),
    isOnSaleAtAddition: json['isOnSaleAtAddition'] ?? false,
  );
}
