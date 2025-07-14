import 'package:agrimarket/data/models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderRepository {
  final CollectionReference _ordersCollection = FirebaseFirestore.instance.collection('orders');

  Future<void> createOrder(OrderModel order) async {
    try {
      print('Creating order in repository with ID: ${order.orderId}');
      print('Order store ID: ${order.storeId}');
      print('Order buyer ID: ${order.buyerUid}');
      print('Order items count: ${order.items.length}');

      // Use the orderId as the document ID for easier querying
      await _ordersCollection.doc(order.orderId).set(order.toJson());
      print('Order created successfully in Firestore');
    } catch (e) {
      print('Error creating order in repository: $e');
      throw Exception('Failed to create order in repository: $e');
    }
  }

  Future<List<OrderModel>> getOrdersByStoreId(String storeId) async {
    try {
      print('Getting orders for store ID: $storeId');
      final querySnapshot =
          await _ordersCollection.where('storeId', isEqualTo: storeId).orderBy('createdAt', descending: true).get();

      final orders =
          querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return OrderModel.fromJson(data);
          }).toList();

      print('Found ${orders.length} orders for store: $storeId');
      return orders;
    } catch (e) {
      print('Error getting orders by store ID: $e');
      throw Exception('Failed to get orders by store ID: $e');
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order by ID: $e');
    }
  }

  Future<void> updateOrder(String orderId, OrderModel order) async {
    try {
      await _ordersCollection.doc(orderId).update(order.toJson());
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _ordersCollection.doc(orderId).delete();
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  // Get orders by buyer ID
  Future<List<OrderModel>> getOrdersByBuyerId(String buyerId) async {
    try {
      final querySnapshot =
          await _ordersCollection.where('buyerUid', isEqualTo: buyerId).orderBy('createdAt', descending: true).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get orders by buyer ID: $e');
    }
  }

  // Get orders by status
  Future<List<OrderModel>> getOrdersByStatus(String storeId, String status) async {
    try {
      final querySnapshot =
          await _ordersCollection
              .where('storeId', isEqualTo: storeId)
              .where('status', isEqualTo: status)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  Future<void> updateOrdersCommissionPaidStatus(List<String> orderIds, bool isCommissionPaid) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      for (String orderId in orderIds) {
        final orderRef = _ordersCollection.doc(orderId);
        batch.update(orderRef, {'isCommissionPaid': isCommissionPaid, 'updatedAt': Timestamp.fromDate(DateTime.now())});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update commission paid status: $e');
    }
  }
}
