import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/utils/cache_utils.dart';
import 'package:agrimarket/core/widgets/promotion_badge.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/store_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryStoreScreen extends StatelessWidget {
  final StoreVm storeVm = Get.find<StoreVm>();
  final String category;

  CategoryStoreScreen({super.key}) : category = (Get.arguments is String) ? Get.arguments : '' {
    // Initialize data after widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      storeVm.fetchStoresByCategory(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(category, style: AppTextStyles.headline),
        centerTitle: true,
        backgroundColor: AppColors.background,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.bug_report),
        //     onPressed: () {
        //       storeVm.debugAllStores();
        //     },
        //     tooltip: 'Debug - Check all stores',
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.storage),
        //     onPressed: () async {
        //       await CacheUtils.checkAndRepairCache();
        //       final stats = CacheUtils.getCacheStats();
        //       print('📊 Cache stats: $stats');
        //     },
        //     tooltip: 'Debug - Check cache',
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          storeVm.fetchStoresByCategory(category);
        },
        child: Column(
          children: [
            // Thanh lọc UI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      dropdownColor: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      value: storeVm.filterType.value,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                        DropdownMenuItem(value: 'opened', child: Text('Đang mở cửa')),
                        DropdownMenuItem(value: 'promotion', child: Text('Khuyến mãi')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          storeVm.setFilter(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: storeVm.toggleSortOrder,
                    icon: Obx(
                      () => Icon(
                        storeVm.isAscending.value ? Icons.arrow_upward : Icons.arrow_downward,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách cửa hàng
            Expanded(
              child: Obx(() {
                final filteredStores = storeVm.getFilteredStores();

                if (storeVm.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (filteredStores.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Không tìm thấy cửa hàng nào trong danh mục này.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredStores.length,
                  itemBuilder: (context, index) {
                    final store = filteredStores[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.store, arguments: store);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PromotionBadgeOverlay(
                              isPromotion: store.isPromotion,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  store.storeImageUrl ?? '',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.store, size: 50),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(store.name, style: AppTextStyles.headline.copyWith(fontSize: 16)),
                                  const SizedBox(height: 6),
                                  Text(
                                    store.storeLocation.address,
                                    style: AppTextStyles.body.copyWith(fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
