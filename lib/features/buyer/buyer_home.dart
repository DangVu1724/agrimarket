import 'package:agrimarket/features/buyer/home/view/buyer_home_screen.dart';
import 'package:agrimarket/features/buyer/orders/view/order_screen.dart';
import 'package:agrimarket/features/buyer/search/view/search_screen.dart';
import 'package:agrimarket/features/buyer/buyer_vm.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../app/theme/app_colors.dart';
import 'profile/view/profile_screen.dart';

class BuyerHome extends StatelessWidget {
  BuyerHome({super.key});

  final RxInt _currentIndex = 0.obs;
  final BuyerVm buyerVm = Get.find<BuyerVm>();
  final UserVm userVm = Get.find<UserVm>();

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return HomeBuyerScreen();
      case 1:
        return SearchScreen();
      case 2:
        return const OrdersScreen();
      case 3:
        return ProfileScreen();
      default:
        return HomeBuyerScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => _buildScreen(_currentIndex.value)),
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
            BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
            BottomNavigationBarItem(icon: Icon(Iconsax.receipt_item), label: 'Đơn hàng'),
            BottomNavigationBarItem(icon: Icon(Iconsax.user_square), label: 'Tài khoản'),
          ],
        ),
      ),
    );
  }
}
