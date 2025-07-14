import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:agrimarket/features/seller/chat/view/seller_chat_screen.dart';
import 'package:agrimarket/features/seller/home/view/seller_home_screen.dart';
import 'package:agrimarket/features/seller/orders/view/orderList_screen.dart';
import 'package:agrimarket/features/seller/profile/view/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerHome extends StatelessWidget {
  SellerHome({super.key});

  final RxInt _currentIndex = 0.obs;
  final UserVm userVm = Get.find<UserVm>();

  // Lazy initialize screens to prevent renderObject errors
  Widget _getScreen(int index) {
    try {
      switch (index) {
        case 0:
          return const SellerHomeScreen();
        case 1:
          return const OrderlistScreen();
        case 2:
          return const SellerChatScreen();
        case 3:
          return SellerProfileScreen();
        default:
          return const Center(child: Text('Màn hình không tồn tại'));
      }
    } catch (e) {
      print('❌ Error loading screen at index $index: $e');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi tải màn hình: $e'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _currentIndex.value = 0; // Reset to home screen
              },
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        try {
          return _getScreen(_currentIndex.value);
        } catch (e) {
          print('❌ Error in SellerHome build: $e');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Đã xảy ra lỗi'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _currentIndex.value = 0;
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex.value,
          onTap: (index) {
            try {
              _currentIndex.value = index;
            } catch (e) {
              print('❌ Error switching to index $index: $e');
              _currentIndex.value = 0; // Fallback to home
            }
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Đơn hàng'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Trò chuyện'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
          ],
        ),
      ),
    );
  }
}
