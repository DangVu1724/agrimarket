import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/skeleton_loader.dart';
import 'package:agrimarket/core/widgets/promotion_badge.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BuyerVm vm = Get.find<BuyerVm>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.getFavoriteStores();
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Yêu Thích', style: AppTextStyles.headline.copyWith(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (vm.isLoading.value && vm.favoriteStores.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.favoriteStores.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('Chưa có cửa hàng yêu thích', style: AppTextStyles.headline.copyWith(color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text(
                  'Thêm cửa hàng yêu thích từ trang chi tiết!',
                  style: AppTextStyles.body.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => vm.getFavoriteStores(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            itemCount: vm.favoriteStores.length,
            itemBuilder: (context, index) {
              final store = vm.favoriteStores[index];
              return AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedSlide(
                  offset: Offset(0, index * 0.05),
                  duration: const Duration(milliseconds: 300),
                  child: _StoreCard(store: store, onRemove: () => vm.toggleFavoriteStore(store.storeId)),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onRemove;

  const _StoreCard({required this.store, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed(AppRoutes.store, arguments: store.storeId);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh cửa hàng
              PromotionBadgeOverlay(
                isPromotion: store.isPromotion,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl:
                        store.storeImageUrl ??
                        'https://images.unsplash.com/photo-1582407947304-fd86f028f716?auto=format&fit=crop&w=800&q=80',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) =>
                            Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator())),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: AppTextStyles.headline.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.storeLocation.address,
                      style: AppTextStyles.body.copyWith(color: Colors.grey.shade600, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: store.isOpened ? Colors.green : Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          store.isOpened ? 'Mở cửa' : 'Đóng cửa',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            color: store.isOpened ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Nút xóa yêu thích
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Skeleton loading
