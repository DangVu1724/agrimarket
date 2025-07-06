import 'dart:async';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/data/services/order_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm .dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuyerOrderVm extends GetxController {
  final RxList<OrderModel> unconfirmedOrders = <OrderModel>[].obs;
  final RxList<OrderModel> confirmedOrders = <OrderModel>[].obs;
  final RxList<OrderModel> shippedOrders = <OrderModel>[].obs;
  final RxList<OrderModel> deliveredOrders = <OrderModel>[].obs;
  final RxList<OrderModel> cancelledOrders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final OrderService orderService = OrderService();

  StreamSubscription<QuerySnapshot>? _ordersSubscription;
  String? _currentBuyerId;
  


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
}
