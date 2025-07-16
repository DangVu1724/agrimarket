import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/core/widgets/custom_app_bar.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../app/theme/app_text_styles.dart';

class SellerProfileScreen extends StatelessWidget {
  SellerProfileScreen({super.key});
  final UserVm vm = Get.find<UserVm>();
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> sectionItems = [
      {'icon': Iconsax.tag_user, 'title': 'Thông tin cá nhân'},
      {'icon': Iconsax.location, 'title': 'Thông tin cửa hàng'},
      {'icon': Iconsax.setting_2, 'title': 'Cài đặt'},
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomAppBar(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                color: Colors.white
                              ),
                            ),
                          ),
                          Obx(
                            () => SizedBox(
                              width: 200,
                              child: Text(
                                vm.userEmail.value.isNotEmpty
                                    ? vm.userEmail.value
                                    : 'Chưa cập nhật email',
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                              
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Transform.translate(
                  offset: const Offset(0, -60),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children:
                          sectionItems
                              .map(
                                (item) =>
                                    _buildSectionButton(item['icon'], item['title']),
                              )
                              .toList(),
                    ),
                  ),
                ),
              ],
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
            case 'Thông tin cửa hàng':
              Get.toNamed(AppRoutes.storeInfo);
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
