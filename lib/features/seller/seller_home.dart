import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/orders/view/order_screen.dart';
import 'package:agrimarket/features/buyer/profile/view/profile_screen.dart';
import 'package:agrimarket/features/buyer/search/view/search_screen.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:agrimarket/features/seller/chat/view/seller_chat_screen.dart';
import 'package:agrimarket/features/seller/home/view/seller_home_screen.dart';
import 'package:agrimarket/features/seller/orders/view/orderList_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerHome extends StatelessWidget {

  SellerHome({super.key});

  final RxInt _currentIndex = 0.obs;
  final UserVm userVm = Get.find<UserVm>();

  final List<Widget> _screens = [
    SellerHomeScreen(),
    const OrderlistScreen(),
    const SellerChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => _screens[_currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex.value,
          onTap: (index) => _currentIndex.value = index,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Đơn hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Trò chuyện',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }
}