import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SimpleNotificationService {
  // Singleton pattern
  static final SimpleNotificationService _instance = SimpleNotificationService._internal();
  factory SimpleNotificationService() => _instance;
  SimpleNotificationService._internal();

  // Thông báo đơn hàng mới
  void showNewOrderNotification({required String orderId, required String buyerName, required double totalAmount}) {
    Get.snackbar(
      '🛒 Đơn hàng mới',
      'Có đơn hàng mới từ $buyerName\nGiá trị: ${_formatPrice(totalAmount)}\nMã đơn: $orderId',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
      onTap: (snack) {
        // Có thể thêm navigation đến màn hình đơn hàng ở đây
        Get.snackbar(
          'Thông báo',
          'Chuyển đến đơn hàng: $orderId',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      },
    );
  }

  // Thông báo cập nhật trạng thái đơn hàng
  void showOrderStatusUpdateNotification({required String orderId, required String newStatus}) {
    Get.snackbar(
      '📦 Cập nhật đơn hàng',
      'Đơn hàng $orderId đã được cập nhật thành $_getStatusText(newStatus)',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      backgroundColor: const Color(0xFF2196F3),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.update, color: Colors.white, size: 24),
    );
  }

  // Thông báo đơn giản
  void showSimpleNotification({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      duration: duration,
      backgroundColor: const Color(0xFF333333),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Format giá tiền
  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(price);
  }

  // Chuyển đổi trạng thái sang tiếng Việt
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'shipped':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }
}
