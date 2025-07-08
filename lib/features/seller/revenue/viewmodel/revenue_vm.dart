import 'package:agrimarket/data/services/revenue_service.dart';
import 'package:agrimarket/features/seller/orders/viewmodel/seller_orders_vm.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class RevenueVm extends GetxController {
  final RevenueService _revenueService = RevenueService();
  final SellerOrdersVm _sellerOrdersVm = Get.find();

  final RxList<Map<String, dynamic>> revenueList = <Map<String, dynamic>>[].obs;
  final RxBool isRealtimeEnabled = false.obs;
  final Rx<DateTime> lastUpdated = DateTime.now().obs;

  Timer? _realtimeTimer;
  static const Duration _refreshInterval = Duration(seconds: 30); // Cập nhật mỗi 30 giây

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  @override
  void onClose() {
    stopRealtimeUpdates();
    super.onClose();
  }

  /// Bắt đầu cập nhật realtime
  void startRealtimeUpdates() {
    if (isRealtimeEnabled.value) return;

    isRealtimeEnabled.value = true;
    _realtimeTimer = Timer.periodic(_refreshInterval, (timer) {
      refreshData();
    });
  }

  /// Dừng cập nhật realtime
  void stopRealtimeUpdates() {
    if (!isRealtimeEnabled.value) return;

    isRealtimeEnabled.value = false;
    _realtimeTimer?.cancel();
    _realtimeTimer = null;
  }

  /// Toggle realtime updates
  void toggleRealtimeUpdates() {
    if (isRealtimeEnabled.value) {
      stopRealtimeUpdates();
    } else {
      startRealtimeUpdates();
    }
  }

  /// Lấy và xử lý dữ liệu doanh thu từ các đơn hàng đã giao
  Future<void> refreshData() async {
    try {
      final orders = _sellerOrdersVm.orders;

      // Gom nhóm doanh thu theo ngày
      final Map<String, double> revenueMap = {};
      for (var order in orders) {
        if (order.status == 'delivered' && order.deliveredAt != null) {
          String dateKey = DateFormat('dd/MM/yyyy').format(order.deliveredAt!);

          revenueMap[dateKey] = (revenueMap[dateKey] ?? 0) + order.totalPrice * RevenueService.APP_COMMISSION_RATE;
        }
      }

      // Chuyển map -> list để hiển thị biểu đồ
      final list =
          revenueMap.entries.map((entry) {
            return {'date': entry.key, 'revenue': entry.value};
          }).toList();

      // Sắp xếp theo ngày tăng dần
      list.sort((a, b) => DateTime.parse(a['date'] as String).compareTo(DateTime.parse(b['date'] as String)));

      final recent30days = list.length > 30 ? list.sublist(list.length - 30) : list;

      // Cập nhật observable
      revenueList.assignAll(recent30days);
      lastUpdated.value = DateTime.now();
    } catch (e) {
      print('Error refreshing revenue data: $e');
    }
  }
}
