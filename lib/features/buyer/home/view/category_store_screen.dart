import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/storetile.dart';
import 'package:agrimarket/data/services/address_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/store_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CategoryStoreScreen extends StatelessWidget {
  final StoreVm storeVm = Get.find<StoreVm>();
  final BuyerVm vm = Get.find<BuyerVm>();
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
                  // Dropdown lọc
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: InputBorder.none, // bỏ viền mặc định
                        ),
                        dropdownColor: Colors.white,
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
                  ),
                  const SizedBox(width: 8),

                  // Nút sắp xếp theo đánh giá
                  Obx(
                    () => IconButton(
                      tooltip:
                          storeVm.isAscending.value
                              ? 'Sắp xếp theo đánh giá (Tăng dần)'
                              : 'Sắp xếp theo đánh giá (Giảm dần)',
                      onPressed: () {
                        storeVm.setSortBy('rating');
                        storeVm.toggleSortOrder();
                      },
                      icon: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: storeVm.sortBy.value == 'rating' ? AppColors.primary : Colors.grey[500],
                          ),
                          Icon(
                            storeVm.isAscending.value ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 14,
                            color: storeVm.sortBy.value == 'rating' ? AppColors.primary : Colors.grey[500],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Nút sắp xếp theo khoảng cách
                  Obx(
                    () => IconButton(
                      tooltip:
                          storeVm.isDistanceAscending.value
                              ? 'Sắp xếp theo khoảng cách (Tăng dần)'
                              : 'Sắp xếp theo khoảng cách (Giảm dần)',
                      onPressed: () {
                        storeVm.setSortBy('distance');
                        storeVm.toggleDistanceSortOrder();
                      },
                      icon: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.near_me,
                            color: storeVm.sortBy.value == 'distance' ? AppColors.primary : Colors.grey[500],
                          ),
                          Icon(
                            storeVm.isDistanceAscending.value ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 14,
                            color: storeVm.sortBy.value == 'distance' ? AppColors.primary : Colors.grey[500],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách cửa hàng
            Expanded(
              child: Obx(() {
                final buyer = vm.buyerData.value;
                final buyerLatLng = buyer?.getDefaultLatLng();
                final filteredStores = storeVm.getFilteredStores(
                  buyerLat: buyerLatLng != null ? buyerLatLng[0] : null,
                  buyerLng: buyerLatLng != null ? buyerLatLng[1] : null,
                );

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
                    final buyer = vm.buyerData.value;
                    if (buyer == null) {
                      return SizedBox.shrink();
                    }

                    final addressService = AddressService();
                    final storeLatLng = store.getDefaultLatLng();
                    final buyerLatLng = buyer.getDefaultLatLng();

                    if (storeLatLng == null || buyerLatLng == null) {
                      return StoreTile(store: store, distanceText: null, estimatedTime: null);
                    }

                    final distance = addressService.calculateDistance(
                      buyerLatLng[0],
                      buyerLatLng[1],
                      storeLatLng[0],
                      storeLatLng[1],
                    );
                    final formattedDistance = NumberFormat('#,##0.00', 'vi_VN').format(distance);

                    return FutureBuilder<int>(
                      future: addressService.getEstimatedTravelTime(
                        storeLatLng[0],
                        storeLatLng[1],
                        buyerLatLng[0],
                        buyerLatLng[1],
                      ),
                      builder: (context, snapshot) {
                        final estimatedTime = snapshot.hasData ? snapshot.data! : 0;
                        final int prepareTime = 15;
                        final int totalTime = prepareTime + estimatedTime;

                        return StoreTile(store: store, distanceText: '$formattedDistance km', estimatedTime: totalTime);
                      },
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
