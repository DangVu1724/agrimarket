import 'dart:async';
import 'package:agrimarket/data/services/store_promotion_service.dart';
import 'package:get/get.dart';

class BackgroundPromotionService {
  final StorePromotionService _storePromotionService = StorePromotionService();
  Timer? _periodicTimer;
  Timer? _dailyTimer;

  static const Duration _checkInterval = Duration(minutes: 30); // Kiểm tra mỗi 30 phút
  static const Duration _dailyCheckInterval = Duration(hours: 24); // Kiểm tra hàng ngày

  /// Khởi động background service
  void startBackgroundService() {
    print('🚀 Starting background promotion service...');

    // Kiểm tra định kỳ mỗi 30 phút
    _periodicTimer = Timer.periodic(_checkInterval, (timer) {
      _checkAndUpdateAllStores();
    });

    // Kiểm tra hàng ngày lúc 00:00
    _scheduleDailyCheck();

    print('✅ Background promotion service started');
  }

  /// Dừng background service
  void stopBackgroundService() {
    print('🛑 Stopping background promotion service...');

    _periodicTimer?.cancel();
    _dailyTimer?.cancel();

    _periodicTimer = null;
    _dailyTimer = null;

    print('✅ Background promotion service stopped');
  }

  /// Lên lịch kiểm tra hàng ngày
  void _scheduleDailyCheck() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = nextMidnight.difference(now);

    _dailyTimer = Timer(timeUntilMidnight, () {
      _checkAndUpdateAllStores();

      // Lên lịch cho ngày tiếp theo
      _scheduleDailyCheck();
    });

    print('📅 Scheduled daily promotion check for ${nextMidnight.toString()}');
  }

  /// Kiểm tra và cập nhật tất cả stores
  Future<void> _checkAndUpdateAllStores() async {
    try {
      print('🔄 Background: Checking promotion status for all stores...');
      await _storePromotionService.updateAllStoresPromotionStatus();
      print('✅ Background: Completed promotion status update for all stores');
    } catch (e) {
      print('❌ Background: Error updating promotion status: $e');
    }
  }

  /// Kiểm tra thủ công tất cả stores
  Future<void> manualCheckAllStores() async {
    try {
      print('🔍 Manual: Checking promotion status for all stores...');
      await _storePromotionService.updateAllStoresPromotionStatus();
      print('✅ Manual: Completed promotion status update for all stores');
      Get.snackbar('Thành công', 'Đã cập nhật trạng thái khuyến mãi cho tất cả stores');
    } catch (e) {
      print('❌ Manual: Error updating promotion status: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái khuyến mãi: $e');
    }
  }

  /// Kiểm tra thủ công một store cụ thể
  Future<void> manualCheckStore(String storeId) async {
    try {
      print('🔍 Manual: Checking promotion status for store: $storeId');
      await _storePromotionService.updateStorePromotionStatus(storeId);
      print('✅ Manual: Completed promotion status update for store: $storeId');
      Get.snackbar('Thành công', 'Đã cập nhật trạng thái khuyến mãi cho store');
    } catch (e) {
      print('❌ Manual: Error updating promotion status for store $storeId: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái khuyến mãi: $e');
    }
  }

  /// Dispose service
  void dispose() {
    stopBackgroundService();
  }
}
