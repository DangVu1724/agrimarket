class OrderModel {
  final String orderId;
  final String buyerUid;
  final String storeId;
  final List<OrderItem> items;
  final String status; 
  final double totalPrice;
  final DateTime createdAt;
  final String deliveryAddress;

  OrderModel({
    required this.orderId,
    required this.buyerUid,
    required this.storeId,
    required this.items,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.deliveryAddress,
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
