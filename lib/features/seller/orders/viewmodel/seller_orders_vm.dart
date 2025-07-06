import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/data/services/order_service.dart';
import 'package:agrimarket/data/services/seller_store_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SellerOrdersVm extends GetxController {
  final OrderService _orderService = OrderService();
  final SellerStoreService _sellerStoreService = SellerStoreService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt pendingOrdersCount = 0.obs;
  final RxInt totalOrdersCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _clearData();
    _setupRealTimeListeners();
  }

  void _clearData() {
    orders.clear();
    errorMessage.value = '';
    pendingOrdersCount.value = 0;
    totalOrdersCount.value = 0;
  }

  void _setupRealTimeListeners() async {
    try {
      final storeId = await _getCurrentStoreId();
      if (storeId == null) {
        errorMessage.value = 'Không tìm thấy cửa hàng của bạn';
        return;
      }

      _orderService.listenToOrdersByStoreId(
        storeId: storeId,
        onOrdersChanged: (List<OrderModel> newOrders) {
          orders.assignAll(newOrders);
          _updateOrderCounts();
        },
        onError: (error) {
          errorMessage.value = 'Lỗi kết nối: $error';
        },
      );
    } catch (e) {
      errorMessage.value = 'Lỗi khởi tạo: $e';
    }
  }

  Future<String?> _getCurrentStoreId() async {
    try {
      final store = await _sellerStoreService.getCurrentSellerStore();
      return store?.storeId;
    } catch (e) {
      return null;
    }
  }

  void _updateOrderCounts() {
    pendingOrdersCount.value = orders.where((order) => order.status == 'pending').length;
    totalOrdersCount.value = orders.length;
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final index = orders.indexWhere((order) => order.orderId == orderId);
      if (index == -1) {
        print('Không tìm thấy orderId: $orderId để cập nhật trạng thái');
        return;
      }

      final order = orders[index];
      final updatedOrder = order.copyWith(status: newStatus);

      await _orderService.updateOrder(orderId, updatedOrder);

      orders[index] = updatedOrder;
      _updateOrderCounts();
    } catch (e) {
      print('Lỗi cập nhật trạng thái đơn hàng: $e');
    }
  }

  // Các getter đơn hàng theo trạng thái
  List<OrderModel> getOrdersByStatus(String status) => orders.where((order) => order.status == status).toList();
  List<OrderModel> getPendingOrders() => getOrdersByStatus('pending');
  List<OrderModel> getConfirmedOrders() => getOrdersByStatus('confirmed');
  List<OrderModel> getShippedOrders() => getOrdersByStatus('shipped');
  List<OrderModel> getDeliveredOrders() => getOrdersByStatus('delivered');
  List<OrderModel> getCancelledOrders() => getOrdersByStatus('cancelled');

  Future<void> refreshData() async {
    print('🔄 Refreshing data...');
    _clearData();
    _orderService.disposeListeners();
    _setupRealTimeListeners();
  }

  @override
  void onClose() {
    _orderService.disposeListeners();
    super.onClose();
  }
}
