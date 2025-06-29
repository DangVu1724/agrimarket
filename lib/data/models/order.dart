class OrderModel {
  final String orderId;
  final String buyerUid;
  final String storeId;
  final List<OrderItem> items;
  final String status; 
  final double totalPrice;
  final DateTime createdAt;
  final String deliveryAddress;
  final String? discountCodeId;

  OrderModel({
    required this.orderId,
    required this.buyerUid,
    required this.storeId,
    required this.items,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.deliveryAddress,
    this.discountCodeId
  });
}

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String unit;
  

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.unit,
  });
}
