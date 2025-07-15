import 'dart:async';

import 'dart:async';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/data/repo/order_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class OrderService {
  final OrderRepository _orderRepository = OrderRepository();
  final _uuid = Uuid();
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  Future<String> createOrder(OrderModel order) async {
    try {
      // Generate unique order ID if not provided
      final orderWithId = order.orderId.isEmpty ? order.copyWith(orderId: _uuid.v4()) : order;

      await _orderRepository.createOrder(orderWithId);
      return orderWithId.orderId;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  void listenToOrdersByStoreId({
    required String storeId,
    required Function(List<OrderModel>) onOrdersChanged,
    required Function(String) onError,
  }) {
    // Dispose existing listener if any
    _ordersSubscription?.cancel();

    try {
      _ordersSubscription = FirebaseFirestore.instance
          .collection('orders')
          .where('storeId', isEqualTo: storeId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
              try {
                final orders =
                    snapshot.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return OrderModel.fromJson(data);
                    }).toList();

                onOrdersChanged(orders);
              } catch (e) {
                onError('Error parsing orders: $e');
              }
            },
            onError: (error) {
              onError('Error listening to orders: $error');
            },
          );
    } catch (e) {
      onError('Error setting up listener: $e');
    }
  }

  void disposeListeners() {
    _ordersSubscription?.cancel();
    _ordersSubscription = null;
  }

  Future<List<OrderModel>> getOrdersByStoreId(String storeId) async {
    try {
      return await _orderRepository.getOrdersByStoreId(storeId);
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      return await _orderRepository.getOrderById(orderId);
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  Future<List<OrderModel>> getOrdersByStatus(String buyerId, String status) async {
    try {
      final orders = await _orderRepository.getOrdersByBuyerId(buyerId);
      return orders.where((order) => order.status == status).toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  Future<List<OrderModel>> getOrdersByBuyerId(String buyerId) async {
    try {
      return await _orderRepository.getOrdersByBuyerId(buyerId);
    } catch (e) {
      throw Exception('Failed to get orders by buyer ID: $e');
    }
  }

  Future<void> updateOrder(String orderId, OrderModel order) async {
    try {
      await _orderRepository.updateOrder(orderId, order);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _orderRepository.deleteOrder(orderId);
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  Future<void> updateOrdersCommissionPaidStatus(List<String> orderIds, bool isCommissionPaid) async {
    try {
      await _orderRepository.updateOrdersCommissionPaidStatus(orderIds, isCommissionPaid);
    } catch (e) {
      throw Exception('Failed to update commission paid status: $e');
    }
  }

  Future<void> submitReview({required String orderId, required double rating, required String comment, required String storeId, required String buyerUid}) async {
    try {
      await _orderRepository.submitReview(orderId: orderId, rating: rating, comment: comment, storeId: storeId, buyerUid: buyerUid);
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  Future<void> updateStoreAverageRating(String storeId) async {
    try {
      await _orderRepository.updateStoreAverageRating(storeId);
    } catch (e) {
      throw Exception('Failed to update store average rating: $e');
    }
  }
}
