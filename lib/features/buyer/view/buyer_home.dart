import 'package:agrimarket/features/buyer/view/buyer_home_screen.dart';
import 'package:agrimarket/features/buyer/view/order_screen.dart';
import 'package:agrimarket/features/buyer/view/search_screen.dart';
import 'package:agrimarket/features/buyer/viewmodel/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/viewmodel/user_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import 'profile_screen.dart';

class BuyerHome extends StatelessWidget {

  BuyerHome({super.key});

  final RxInt _currentIndex = 0.obs;
  final BuyerVm buyerVm = Get.find<BuyerVm>();
  final UserVm userVm = Get.find<UserVm>();

  final List<Widget> _screens = [
    HomeBuyerScreen(),
    const OrdersScreen(),
    const SearchScreen(),
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
              icon: Icon(Icons.shopping_cart),
              label: 'Tìm kiếm',
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