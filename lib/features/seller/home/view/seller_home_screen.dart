import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:agrimarket/features/seller/orders/viewmodel/seller_orders_vm.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SellerHomeVm vm = Get.find<SellerHomeVm>();
    final SellerOrdersVm ordersVm = Get.find<SellerOrdersVm>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        try {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Text(
                          'Chào mừng, ${vm.store.value?.name ?? 'Cửa hàng của bạn'}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        ' ${vm.store.value?.state ?? 'pending'}',
                        style: TextStyle(fontSize: 12, color: vm.storeStateColor.value, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12.0)),
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.revenue);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(Icons.account_balance_wallet, size: 30, color: Colors.white),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            const Text('Doanh thu hôm nay', style: TextStyle(fontSize: 14, color: Colors.white)),
                            Text(
                              NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: '₫',
                                decimalDigits: 0,
                              ).format(ordersVm.getDailyCommission()),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Hôm qua', style: TextStyle(fontSize: 14, color: Colors.white)),
                            Text(
                              NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: '₫',
                                decimalDigits: 0,
                              ).format(ordersVm.getYesterdayCommission()),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
          );
        } catch (e) {
          print('❌ Error in SellerHomeScreen build: $e');
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
                    // Force refresh
                    vm.refresh();
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  Widget _buildCategoryIcons() {
    final SellerHomeVm vm = Get.find<SellerHomeVm>();

    return Obx(() {
      try {
        final items = [
          'Đơn hàng',
          'Menu',
          'Sản phẩm',
          'Khuyến mãi',
          'Tài chính',
          'Doanh thu',
          'Nhân viên',
          vm.isOpened.value ? 'Mở cửa hàng' : 'Đóng cửa hàng',
        ];
        final List<String> iconEmojis = [
          '🛒', // Đơn hàng
          '📖', // Menu
          '🌾', // Sản phẩm
          '🏷️', // Khuyến mãi
          '🧭', // Tài chính
          '💰', // Doanh thu
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
                  try {
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
                      case 5:
                        Get.toNamed(AppRoutes.revenue);
                        break;
                      case 4:
                        Get.toNamed(AppRoutes.sellerFinancial);
                        break;
                      case 7:
                        vm.toggleOpen();
                        break;
                      default:
                        Get.snackbar("Category Clicked", "Bạn đã nhấn vào danh mục ${items[index]}");
                    }
                  } catch (e) {
                    print('❌ Error in category tap: $e');
                    Get.snackbar("Lỗi", "Không thể mở màn hình này");
                  }
                },
                child: SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: AppColors.textSecondary),
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
      } catch (e) {
        print('❌ Error in _buildCategoryIcons: $e');
        return const Center(child: Text('Không thể tải danh mục'));
      }
    });
  }

  Widget _buildBanner() {
    try {
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
          autoPlay: false, // Tắt autoPlay để tránh lỗi
        ),
        items:
            bannerImages.map((imageBanner) {
              return _buildBannerItem(imageBanner);
            }).toList(),
      );
    } catch (e) {
      print('❌ Error in _buildBanner: $e');
      return Container(
        height: 200,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(14)),
        child: const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
      );
    }
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
            onError: (exception, stackTrace) {
              print('❌ Error loading banner image: $imageBanner');
            },
          ),
        ),
      ),
    );
  }
}
