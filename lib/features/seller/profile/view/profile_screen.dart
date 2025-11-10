import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/custom_app_bar.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SellerProfileScreen extends StatelessWidget {
  SellerProfileScreen({super.key});
  final UserVm vm = Get.find<UserVm>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          await vm.loadUserData();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header với avatar và thông tin
            SliverAppBar(
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary!,
                        AppColors.primary!.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Obx(() => CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage:
                          vm.userAvatar.value.isNotEmpty &&
                              vm.userAvatar.value.startsWith('http')
                              ? NetworkImage(vm.userAvatar.value)
                              : const AssetImage('assets/images/avatar.png')
                          as ImageProvider,
                        )),

                        const SizedBox(width: 16),

                        // Thông tin user
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => Text(
                                vm.userName.value.isNotEmpty
                                    ? vm.userName.value
                                    : 'Chưa cập nhật tên',
                                style: AppTextStyles.headline.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),

                              const SizedBox(height: 4),

                              Obx(() => Text(
                                vm.userEmail.value.isNotEmpty
                                    ? vm.userEmail.value
                                    : 'Chưa cập nhật email',
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Danh sách chức năng
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),

                // Thông tin cửa hàng
                _buildMenuCard(
                  icon: Iconsax.shop,
                  title: 'Thông tin cửa hàng',
                  subtitle: 'Quản lý thông tin cửa hàng của bạn',
                  onTap: () => Get.toNamed(AppRoutes.storeInfo),
                ),

                // Thông tin cá nhân
                _buildMenuCard(
                  icon: Iconsax.profile_circle,
                  title: 'Thông tin cá nhân',
                  subtitle: 'Cập nhật thông tin tài khoản',
                  onTap: () => Get.toNamed(AppRoutes.buyerAccount),
                ),

                // Cài đặt
                _buildMenuCard(
                  icon: Iconsax.setting_2,
                  title: 'Cài đặt',
                  subtitle: 'Tùy chỉnh ứng dụng',
                  onTap: () => Get.toNamed(AppRoutes.settings),
                ),

                // Đăng xuất
                _buildMenuCard(
                  icon: Iconsax.logout,
                  title: 'Đăng xuất',
                  subtitle: 'Đăng xuất khỏi tài khoản',
                  onTap: () => vm.signOut(),
                  isLogout: true,
                ),

                const SizedBox(height: 20),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[200]!,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLogout
                        ? Colors.red.withOpacity(0.1)
                        : AppColors.primary!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isLogout ? Colors.red : AppColors.primary,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isLogout ? Colors.red : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isLogout ? Colors.red : Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}