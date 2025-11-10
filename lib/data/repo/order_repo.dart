import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderRepository {
  final CollectionReference _ordersCollection = FirebaseFirestore.instance.collection('orders');
  final CollectionReference _storesCollection = FirebaseFirestore.instance.collection('stores');
  final CollectionReference _productCollection = FirebaseFirestore.instance.collection('products');

  Future<void> createOrder(OrderModel order) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore.runTransaction((transaction) async {
        // Kiểm tra tồn kho từng sản phẩm
        for (var item in order.items) {
          final productRef = _productCollection.doc(item.productId);
          final productSnap = await transaction.get(productRef);
          if (!productSnap.exists) {
            throw Exception('Sản phẩm không tồn tại');
          }
          final data = productSnap.data() as Map<String, dynamic>;
          final currentQty = (data['quantity'] as num?)?.toInt() ?? 0;
          if (currentQty < item.quantity) {
            throw Exception('Sản phẩm "${data['name']}" chỉ còn $currentQty cái trong kho');
          }
        }
        // Nếu đủ hàng, trừ tồn kho và tạo đơn hàng
        transaction.set(_ordersCollection.doc(order.orderId), order.toJson());
        for (var item in order.items) {
          final productRef = _productCollection.doc(item.productId);
          transaction.update(productRef, {'quantity': FieldValue.increment(-item.quantity)});
        }
      });
      print('Order created successfully in Firestore (with transaction)');
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

  Future<void> submitReview({
    required String orderId,
    required double rating,
    required String comment,
    required String storeId,
    required String buyerUid,
    required String buyerName,
    List<String>? reviewImages
  }) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'rating': rating,
        'comment': comment,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'isReviewed': true,
        'reviewImages': reviewImages
      });

      final reviewId = _storesCollection.doc(storeId).collection('reviews').doc().id;
      await _storesCollection.doc(storeId).collection('reviews').add({
        'buyerUid': buyerUid,
        'buyerName': buyerName,
        'orderId': orderId,
        'storeId': storeId,
        'rating': rating,
        'comment': comment,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'reviewId': reviewId,
        'reviewImages': reviewImages
      });
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  Future<void> updateStoreAverageRating(String storeId) async {
    try {
      final reviewSnapshot = await _storesCollection.doc(storeId).collection('reviews').get();

      final reviews = reviewSnapshot.docs.map((doc) => Review.fromJson(doc.data())).toList();

      if (reviews.isEmpty) {
        await _storesCollection.doc(storeId).update({'rating': 0.0, 'updatedAt': Timestamp.fromDate(DateTime.now())});
        return;
      }

      final averageRating = reviews.map((e) => e.rating).reduce((a, b) => a + b) / reviews.length;

      await _storesCollection.doc(storeId).update({
        'rating': averageRating,
        'totalReviews': reviews.length,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ Đã cập nhật điểm trung bình: $averageRating');
    } catch (e) {
      throw Exception('❌ Lỗi khi cập nhật rating cửa hàng: $e');
    }
  }
}
