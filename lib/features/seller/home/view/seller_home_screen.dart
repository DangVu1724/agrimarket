import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SellerHomeVm vm = Get.find<SellerHomeVm>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chào mừng, ${vm.store.value?.name ?? 'Cửa hàng của bạn'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' ${vm.store.value?.state}',
                      style: TextStyle(
                        fontSize: 16,
                        color: vm.storeStateColor.value,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: GestureDetector(
                  onTap: () {
                    Get.snackbar('Click', "message");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 30,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          Text(
                            'Doanh thu hôm nay',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          Text(
                            'đ 0đ',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Hôm qua',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          Text(
                            'đ 0đ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildCategoryIcons(),
              const SizedBox(height: 20),
              Text('Có gì mới?', style: AppTextStyles.headline),
              const SizedBox(height: 20),
              _buildBanner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcons() {
    final SellerHomeVm vm = Get.find<SellerHomeVm>();

    return Obx(() {
      final items = [
        'Đơn hàng',
        'Menu',
        'Sản phẩm',
        'Khuyến mãi',
        'Khám phá',
        'Tài chính',
        'Nhân viên',
        vm.isOpened.value ? 'Mở cửa hàng' : 'Đóng cửa hàng',
      ];
      final List<String> iconEmojis = [
        '🛒', // Đơn hàng
        '📖', // Menu
        '🌾', // Sản phẩm
        '🏷️', // Khuyến mãi
        '🧭', // Khám phá
        '💰', // Tài chính
        '👥', // Nhân viên
        vm.isOpened.value ? '🔓' : '🔒',
      ];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(items.length, (index) {
            return GestureDetector(
              onTap: () {
                switch (index) {
                  case 0:
                    Get.toNamed(AppRoutes.sellerOrderList);
                    break;
                  case 1:
                    Get.toNamed(AppRoutes.sellerMenu);
                    break;
                  case 2:
                    Get.toNamed(AppRoutes.sellerProduct);
                    break;
                  case 3:
                    Get.toNamed(AppRoutes.sellerPromotions);
                    break;
                  // case 3:
                  //   Get.toNamed('/finance');
                  //   break;
                  case 4:
                   vm.migrateAddressToObject();
                    break;
                  case 7:
                    vm.toggleOpen();
                    break;
                  default:
                    Get.snackbar(
                      "Category Clicked",
                      "Bạn đã nhấn vào danh mục ${items[index]}",
                    );
                }
              },
              child: SizedBox(
                width: 80,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: AppColors.textSecondary,
                        ),

                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(iconEmojis[index]),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      items[index],
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _buildBanner() {
    final List<String> bannerImages = [
      "assets/images/bannerqc.png",
      "assets/images/bannerqc2.jpg",
      "assets/images/bannerqc3.jpg",
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
        enableInfiniteScroll: true,
        autoPlay: true,
      ),
      items:
          bannerImages.map((imageBanner) {
            return _buildBannerItem(imageBanner);
          }).toList(),
    );
  }

  Widget _buildBannerItem(String imageBanner) {
    return GestureDetector(
      onTap: () {
        Get.snackbar("Banner Clicked", "Bạn đã nhấn vào banner");
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          image: DecorationImage(
            image: AssetImage(imageBanner),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
