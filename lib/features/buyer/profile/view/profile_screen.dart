import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final UserVm vm = Get.find<UserVm>();
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> sectionItems = [
      {'icon': Icons.person, 'title': 'Thông tin cá nhân'},
      {'icon': Icons.location_on, 'title': 'Địa chỉ giao hàng'},
      {'icon': Icons.shopping_bag, 'title': 'Đơn hàng đã mua'},
      {'icon': Icons.favorite, 'title': 'Yêu thích'},
      {'icon': Icons.settings, 'title': 'Cài đặt'},
      {'icon': Icons.logout, 'title': 'Đăng xuất'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          await vm.loadUserData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Obx(
                      () => CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            vm.userAvatar.value.isNotEmpty &&
                                    vm.userAvatar.value.startsWith('http')
                                ? NetworkImage(vm.userAvatar.value)
                                : AssetImage('assets/images/avatar.png')
                                    as ImageProvider,
                      ),
                    ),
          
                    SizedBox(width: 22),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            vm.userName.value.isNotEmpty
                                ? vm.userName.value
                                : 'Chưa cập nhật tên',
                            style: AppTextStyles.headline.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Obx(
                          () => Text(
                            vm.userEmail.value.isNotEmpty
                                ? vm.userEmail.value
                                : 'Chưa cập nhật email',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  children:
                      sectionItems
                          .map(
                            (item) =>
                                _buildSectionButton(item['icon'], item['title']),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionButton(IconData icon, String title) {
    return TextButton(
      onPressed: () async {
        try {
          switch (title) {
            case 'Đăng xuất':
              await vm.signOut();
              break;
            case 'Thông tin cá nhân':
              Get.toNamed(AppRoutes.buyerAccount);
              break;
            case 'Địa chỉ giao hàng':
              Get.toNamed(AppRoutes.buyerAddress);
              break;
            case 'Yêu thích':
              Get.toNamed(AppRoutes.favourite);
              break;
            case 'Cài đặt':
              Get.toNamed(AppRoutes.settings);
              break;
            default:
              Get.snackbar('Tính năng', '$title chưa được hỗ trợ');
          }
        } catch (e, st) {
          debugPrint('Error on button "$title": $e\n$st');
        }
      },

      style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black),
                SizedBox(width: 16),
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
