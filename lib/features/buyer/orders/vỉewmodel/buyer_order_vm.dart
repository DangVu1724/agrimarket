import 'dart:async';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/data/services/order_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm .dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuyerOrderVm extends GetxController {
  final RxList<OrderModel> unconfirmedOrders = <OrderModel>[].obs;
  final RxList<OrderModel> confirmedOrders = <OrderModel>[].obs;
  final RxList<OrderModel> shippedOrders = <OrderModel>[].obs;
  final RxList<OrderModel> deliveredOrders = <OrderModel>[].obs;
  final RxList<OrderModel> cancelledOrders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble rating = 0.0.obs;
  final RxString comment = ''.obs;
  final RxBool isReviewed = false.obs;
  final OrderService orderService = OrderService();
  final commentController = TextEditingController();

  StreamSubscription<QuerySnapshot>? _ordersSubscription;
  String? _currentBuyerId;
  

  void setOrderComment(String? comment, bool reviewed) {
    commentController.text = comment ?? '';
    isReviewed.value = reviewed;
  }


  @override
  void onInit() {
    super.onInit();
    _currentBuyerId = Get.find<BuyerVm>().buyerData.value?.uid;
    if (_currentBuyerId != null) {
      _setupRealTimeOrders();
    }
  }

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    commentController.dispose();
    rating.value = 0;
    comment.value = '';
    isReviewed.value = false;
    super.onClose();
  }

  void _setupRealTimeOrders() {
    if (_currentBuyerId == null) return;

    _ordersSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('buyerUid', isEqualTo: _currentBuyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _processOrders(snapshot.docs);
        });
  }

  void _processOrders(List<QueryDocumentSnapshot> docs) {
    try {
      isLoading.value = true;

      // Clear all lists
      unconfirmedOrders.clear();
      confirmedOrders.clear();
      shippedOrders.clear();
      deliveredOrders.clear();
      cancelledOrders.clear();

      for (var doc in docs) {
        try {
          final orderData = doc.data() as Map<String, dynamic>;
          final order = OrderModel.fromJson({...orderData, 'id': doc.id});

          switch (order.status) {
            case 'pending':
              unconfirmedOrders.add(order);
              break;
            case 'confirmed':
              confirmedOrders.add(order);
              break;
            case 'shipped':
              shippedOrders.add(order);
              break;
            case 'delivered':
              deliveredOrders.add(order);
              break;
            case 'cancelled':
              cancelledOrders.add(order);
              break;
            default:
              unconfirmedOrders.add(order);
          }
        } catch (e) {
          print('Error processing order ${doc.id}: $e');
        }
      }
    } catch (e) {
      print('Error processing orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    if (_currentBuyerId == null) return;

    try {
      isLoading.value = true;

      // Fetch orders for each status
      final unconfirmed = await orderService.getOrdersByStatus(_currentBuyerId!, 'Chưa xác nhận');
      final confirmed = await orderService.getOrdersByStatus(_currentBuyerId!, 'Đã xác nhận');
      final shipped = await orderService.getOrdersByStatus(_currentBuyerId!, 'Đang giao');
      final delivered = await orderService.getOrdersByStatus(_currentBuyerId!, 'Đã giao');
      final cancelled = await orderService.getOrdersByStatus(_currentBuyerId!, 'Đã hủy');

      unconfirmedOrders.assignAll(unconfirmed);
      confirmedOrders.assignAll(confirmed);
      shippedOrders.assignAll(shipped);
      deliveredOrders.assignAll(delivered);
      cancelledOrders.assignAll(cancelled);
    } catch (e) {
      print('Error refreshing orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void loadOrders(String buyerId) {
    _currentBuyerId = buyerId;
    _setupRealTimeOrders();
  }

  Future<void> submitReview({
    required String orderId,
    required double rating,
    required String comment,
    required String storeId,
    required String buyerUid,
  }) async {
    try {
      if (isReviewed.value) {
        Get.snackbar('Thông báo', 'Đơn hàng này đã được đánh giá',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      await orderService.submitReview(orderId: orderId, rating: rating, comment: comment, storeId: storeId, buyerUid: _currentBuyerId!);
      await orderService.updateStoreAverageRating(storeId);
      this.rating.value = rating;
      this.comment.value = comment;
      isReviewed.value = true;
      setOrderComment(comment, true);
    } catch (e) {
      print('Error submitting review: $e');
    }
  }





  Stream<OrderModel> getOrderStream(String orderId) {
    return FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots().map((snapshot) => OrderModel.fromJson(snapshot.data()!));
  }
}
