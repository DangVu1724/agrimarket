import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../buyer_vm .dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_stats.dart';


class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final UserVm vm = Get.find<UserVm>();
  final BuyerVm buyerVm = Get.find<BuyerVm>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header với thông tin user và rank
          SliverAppBar(
            expandedHeight: 280,
            flexibleSpace: FlexibleSpaceBar(
              background: ProfileHeader(vm: vm, buyerVm: buyerVm),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),

          // Stats Cards
          SliverToBoxAdapter(
            child: ProfileStats(buyerVm: buyerVm),
          ),

          // Menu chức năng
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ProfileMenuSection(
                  title: 'Tài khoản',
                  items: [
                    MenuItem(
                      icon: Iconsax.tag_user,
                      title: 'Thông tin cá nhân',
                      color: Colors.blue,
                      route: AppRoutes.buyerAccount,
                    ),
                    MenuItem(
                      icon: Iconsax.location,
                      title: 'Địa chỉ giao hàng',
                      color: Colors.green,
                      route: AppRoutes.buyerAddress,
                    ),
                    MenuItem(
                      icon: Iconsax.heart,
                      title: 'Yêu thích',
                      color: Colors.pink,
                      route: AppRoutes.favourite,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                ProfileMenuSection(
                  title: 'Mua sắm',
                  items: [
                    MenuItem(
                      icon: Iconsax.shopping_bag,
                      title: 'Đơn hàng đã mua',
                      color: Colors.orange,
                      route: AppRoutes.buyerOrders,
                    ),
                    MenuItem(
                      icon: Iconsax.discount_shape,
                      title: 'Voucher',
                      color: Colors.purple,
                      route: AppRoutes.voucher,
                    ),
                    MenuItem(
                      icon: Icons.chat,
                      title: 'Chat với người bán',
                      color: Colors.teal,
                      route: AppRoutes.buyerChatList,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                ProfileMenuSection(
                  title: 'Khác',
                  items: [
                    MenuItem(
                      icon: Iconsax.setting_2,
                      title: 'Cài đặt',
                      color: Colors.grey,
                      route: AppRoutes.settings,
                    ),
                    MenuItem(
                      icon: Icons.logout,
                      title: 'Đăng xuất',
                      color: Colors.red,
                      isLogout: true,
                      onTap: () => vm.signOut(),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}