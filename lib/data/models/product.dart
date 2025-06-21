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
    );
  }
}