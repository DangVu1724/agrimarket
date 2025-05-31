class ProductModel {
  final String id;
  final String storeId;
  final String name;
  final String category; 
  final String description;
  final double price;
  final String unit; 
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.unit,
    required this.imageUrl,
  });
}
