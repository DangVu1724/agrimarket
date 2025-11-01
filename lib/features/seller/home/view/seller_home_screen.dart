import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:agrimarket/features/seller/orders/viewmodel/seller_orders_vm.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      backgroundColor: Colors.grey.shade50,
      body: Obx(() {
        try {
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      ),
                    ),
                  ),
                ),
                backgroundColor: AppColors.primary,
                elevation: 0,
                title: Text(
                  'Chào mừng trở lại!',
                  style: AppTextStyles.headline.copyWith(color: Colors.white),
                ),
              ),

              // Content
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  
                  // Store Status Card
                  _buildStoreStatusCard(vm),
                  
                  const SizedBox(height: 20),
                  
                  // Revenue Card
                  _buildRevenueCard(ordersVm),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  _buildQuickActionsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Banner Section
                  _buildBannerSection(),
                  
                  const SizedBox(height: 20),
                ]),
              ),
            ],
          );
        } catch (e) {
          print('❌ Error in SellerHomeScreen build: $e');
          return _buildErrorState(vm);
        }
      }),
    );
  }

  Widget _buildStoreStatusCard(SellerHomeVm vm) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Store Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
            ),
            child: Icon(
              Icons.store,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          
          // Store Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.store.value?.name ?? 'Cửa hàng của bạn',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: vm.storeStateColor.value.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: vm.storeStateColor.value),
                      ),
                      child: Text(
                        vm.store.value?.state ?? 'pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: vm.storeStateColor.value,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildStoreToggleButton(vm),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreToggleButton(SellerHomeVm vm) {
    return GestureDetector(
      onTap: vm.toggleOpen,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: vm.isOpened.value ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: vm.isOpened.value ? Colors.green : Colors.red,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              vm.isOpened.value ? Icons.check_circle : Icons.circle_outlined,
              size: 14,
              color: vm.isOpened.value ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              vm.isOpened.value ? 'Đang mở' : 'Đã đóng',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: vm.isOpened.value ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(SellerOrdersVm ordersVm) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.analytics, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Doanh thu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.revenue),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Xem chi tiết',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Revenue Data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRevenueItem(
                'Hôm nay',
                ordersVm.getDailyCommission(),
                Icons.today,
              ),
              _buildRevenueItem(
                'Hôm qua',
                ordersVm.getYesterdayCommission(),
                Icons.history,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(String title, double amount, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.white.withOpacity(0.8)),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(
            locale: 'vi_VN',
            symbol: '₫',
            decimalDigits: 0,
          ).format(amount),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    final SellerHomeVm vm = Get.find<SellerHomeVm>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Tính năng nhanh',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildCategoryGrid(vm),
      ],
    );
  }

  Widget _buildCategoryGrid(SellerHomeVm vm) {
    final items = [
      {'title': 'Đơn hàng', 'icon': '🛒', 'route': AppRoutes.sellerOrderList},
      {'title': 'Menu', 'icon': '📖', 'route': AppRoutes.sellerMenu},
      {'title': 'Sản phẩm', 'icon': '🌾', 'route': AppRoutes.sellerProduct},
      {'title': 'Khuyến mãi', 'icon': '🏷️', 'route': AppRoutes.sellerPromotions},
      {'title': 'Tài chính', 'icon': '🧭', 'route': AppRoutes.sellerFinancial},
      {'title': 'Doanh thu', 'icon': '💰', 'route': AppRoutes.revenue},
      {'title': 'Nhân viên', 'icon': '👥', 'route': ''},
      {'title': vm.isOpened.value ? 'Đóng cửa' : 'Mở cửa', 'icon': vm.isOpened.value ? '🔓' : '🔒', 'route': 'toggle'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildCategoryItem(item, vm, index);
        },
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, String> item, SellerHomeVm vm, int index) {
    return GestureDetector(
      onTap: () async {
        try {
          if (item['route'] == 'toggle') {
            vm.toggleOpen();
          } else if (item['route']!.isNotEmpty) {
            Get.toNamed(item['route']!);
          } else {
            Get.snackbar("Thông báo", "Tính năng ${item['title']} đang phát triển");
          }
        } catch (e) {
          print('❌ Error in category tap: $e');
          Get.snackbar("Lỗi", "Không thể mở màn hình này");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item['icon']!,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              item['title']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Tin tức & Khuyến mãi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildBanner(),
      ],
    );
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
          height: 140,
          viewportFraction: 0.85,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 4),
          enlargeCenterPage: true,
          enlargeFactor: 0.2,
        ),
        items: bannerImages.map((imageBanner) {
          return _buildBannerItem(imageBanner);
        }).toList(),
      );
    } catch (e) {
      print('❌ Error in _buildBanner: $e');
      return Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text('Không thể tải banner', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildBannerItem(String imageBanner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imageBanner,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(SellerHomeVm vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            'Đã xảy ra lỗi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vui lòng thử lại sau',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: vm.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}