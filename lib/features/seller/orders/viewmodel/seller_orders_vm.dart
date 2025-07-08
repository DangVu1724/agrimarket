import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/data/services/order_service.dart';
import 'package:agrimarket/data/services/revenue_service.dart';
import 'package:agrimarket/data/services/seller_store_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SellerOrdersVm extends GetxController {
  final OrderService _orderService = OrderService();
  final SellerStoreService _sellerStoreService = SellerStoreService();
  final RevenueService _revenueService = RevenueService();

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
      DateTime? deliveredAt = order.deliveredAt;
      if (newStatus == 'delivered' && deliveredAt == null) {
        deliveredAt = DateTime.now();
      }
      // Cập nhật updatedAt khi thay đổi status
      final updatedOrder = order.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(), // Cập nhật thời gian
        deliveredAt: deliveredAt,
      );

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
  List<OrderModel> getUnPaidOrders() => orders.where((order) => order.isPaid == false).toList();
  List<OrderModel> getUnCommissionPaidOrders() =>
      orders.where((order) => order.isCommissionPaid == false && order.status == 'delivered').toList();

  Future<void> refreshData() async {
    print('🔄 Refreshing data...');
    _clearData();
    _orderService.disposeListeners();
    _setupRealTimeListeners();
  }

  // ========== APP COMMISSION METHODS ==========

  // Commission hôm nay
  double getDailyCommission() => _revenueService.getDailyCommission(orders, DateTime.now());

  // Commission hôm qua
  double getYesterdayCommission() => _revenueService.getYesterdayCommission(orders, DateTime.now());

  // Commission tháng này
  double getMonthlyCommission() => _revenueService.getMonthlyCommission(orders, DateTime.now());

  // Commission năm này
  double getYearlyCommission() => _revenueService.getYearlyCommission(orders, DateTime.now());

  // Doanh thu thực tế của seller (sau khi trừ commission)
  double getSellerNetRevenue() => _revenueService.getSellerNetRevenue(orders, DateTime.now());

  // Tổng commission từ tất cả đơn hàng
  double getTotalCommission() => _revenueService.getTotalCommission(orders);

  Future<void> updateOrdersCommissionPaidStatus(List<String> orderIds, bool isCommissionPaid) async {
    try {
      await _orderService.updateOrdersCommissionPaidStatus(orderIds, isCommissionPaid);

      // Cập nhật local data
      for (int i = 0; i < orders.length; i++) {
        if (orderIds.contains(orders[i].orderId)) {
          orders[i] = orders[i].copyWith(isCommissionPaid: isCommissionPaid, updatedAt: DateTime.now());
        }
      }
    } catch (e) {
      errorMessage.value = 'Lỗi cập nhật trạng thái commission: $e';
    }
  }

  @override
  void onClose() {
    _orderService.disposeListeners();
    super.onClose();
  }
}
