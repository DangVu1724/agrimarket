import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final String category;
  final double price;
  final String unit;
  final int quantity;
  final String imageUrl;
  final String? promotion;
  final double? promotionPrice;
  final DateTime? promotionEndDate;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.imageUrl,
    required this.category,
    required this.quantity,
    this.promotion,
    this.promotionPrice,
    this.promotionEndDate,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        category: json['category'] ?? '',
        id: json['id'] ?? '',
        storeId: json['storeId'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        unit: json['unit'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        promotion: json['promotion'] as String?,
        promotionPrice: (json['promotionPrice'] as num?)?.toDouble(),
        promotionEndDate: json['promotionEndDate'] != null
            ? (json['promotionEndDate'] is Timestamp
                ? (json['promotionEndDate'] as Timestamp).toDate()
                : DateTime.tryParse(json['promotionEndDate'] as String))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'storeId': storeId,
        'name': name,
        'description': description,
        'price': price,
        'unit': unit,
        'imageUrl': imageUrl,
        'category': category,
        'quantity': quantity,
        'promotion': promotion,
        'promotionPrice': promotionPrice,
        'promotionEndDate': promotionEndDate?.toIso8601String(),
      };

  ProductModel copyWith({
    String? id,
    String? storeId,
    String? name,
    String? description,
    String? category,
    double? price,
    String? unit,
    int? quantity,
    String? imageUrl,
    String? promotion,
    double? promotionPrice,
    DateTime? promotionEndDate,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      promotion: promotion,
      promotionPrice: promotionPrice,
      promotionEndDate: promotionEndDate,
    );
  }

  double get displayPrice => isOnSale ? (promotionPrice ?? price) : price;

  bool get isOnSale {
    if (promotionPrice == null || promotion == null) return false;
    if (promotionEndDate == null) return true;
    return DateTime.now().isBefore(promotionEndDate!);
  }

  String get promotionTimeLeft {
    if (!isOnSale || promotionEndDate == null) return '';
    final duration = promotionEndDate!.difference(DateTime.now());
    if (duration.isNegative) return 'Đã hết hạn';
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    return days > 0 ? 'Còn $days ngày' : 'Còn $hours giờ';
  }
}