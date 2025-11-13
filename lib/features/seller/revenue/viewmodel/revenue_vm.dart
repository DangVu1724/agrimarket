import 'package:agrimarket/data/services/revenue_service.dart';
import 'package:agrimarket/features/seller/orders/viewmodel/seller_orders_vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class RevenueVm extends GetxController {
  final RevenueService _revenueService = RevenueService();
  final SellerOrdersVm _sellerOrdersVm = Get.find();

  final RxList<Map<String, dynamic>> revenueList = <Map<String, dynamic>>[].obs;
  final RxBool isRealtimeEnabled = false.obs;
  final Rx<DateTime> lastUpdated = DateTime.now().obs;
  final RxInt selectedPeriodIndex = 0.obs; // 0: Tuần, 1: Tháng, 2: Năm

  Timer? _realtimeTimer;
  static const Duration _refreshInterval = Duration(seconds: 30);

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

  /// Lấy dữ liệu đã được lọc theo period
  List<Map<String, dynamic>> getFilteredData() {
    if (revenueList.isEmpty) return [];

    final now = DateTime.now();
    final filteredData = <Map<String, dynamic>>[];

    switch (selectedPeriodIndex.value) {
      case 0: // Tuần
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        for (var item in revenueList) {
          try {
            final date = DateFormat('dd/MM/yyyy').parse(item['date'] as String);
            if (date.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
              filteredData.add(item);
            }
          } catch (e) {
            print('Error parsing date: ${item['date']}');
          }
        }
        break;

      case 1: // Tháng
        final startOfMonth = DateTime(now.year, now.month, 1);
        for (var item in revenueList) {
          try {
            final date = DateFormat('dd/MM/yyyy').parse(item['date'] as String);
            if (date.isAfter(startOfMonth.subtract(const Duration(days: 1)))) {
              filteredData.add(item);
            }
          } catch (e) {
            print('Error parsing date: ${item['date']}');
          }
        }
        break;

      case 2: // Năm
        final startOfYear = DateTime(now.year, 1, 1);
        for (var item in revenueList) {
          try {
            final date = DateFormat('dd/MM/yyyy').parse(item['date'] as String);
            if (date.isAfter(startOfYear.subtract(const Duration(days: 1)))) {
              filteredData.add(item);
            }
          } catch (e) {
            print('Error parsing date: ${item['date']}');
          }
        }
        break;
    }

    // Sắp xếp theo ngày tăng dần
    filteredData.sort((a, b) {
      try {
        final dateA = DateFormat('dd/MM/yyyy').parse(a['date'] as String);
        final dateB = DateFormat('dd/MM/yyyy').parse(b['date'] as String);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });

    return filteredData;
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
          revenueMap[dateKey] = (revenueMap[dateKey] ?? 0) + order.totalPrice;
        }
      }

      // Chuyển map -> list để hiển thị biểu đồ
      final list = revenueMap.entries.map((entry) {
        return {'date': entry.key, 'revenue': entry.value};
      }).toList();

      // Sắp xếp theo ngày tăng dần
      list.sort((a, b) {
        try {
          final dateA = DateFormat('dd/MM/yyyy').parse(a['date'] as String);
          final dateB = DateFormat('dd/MM/yyyy').parse(b['date'] as String);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });

      // Lấy dữ liệu 90 ngày gần nhất để có đủ dữ liệu cho các filter
      final recentData = list.length > 90 ? list.sublist(list.length - 90) : list;

      // Cập nhật observable
      revenueList.assignAll(recentData);
      lastUpdated.value = DateTime.now();
    } catch (e) {
      print('Error refreshing revenue data: $e');
    }
  }

  /// Tính tổng doanh thu từ dữ liệu đã lọc
  double getTotalRevenue() {
    final filteredData = getFilteredData();
    return filteredData.fold<double>(
      0,
      (sum, item) => sum + (item['revenue'] as num).toDouble(),
    );
  }
}