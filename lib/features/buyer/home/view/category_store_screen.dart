import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/store_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryStoreScreen extends StatelessWidget {
  final StoreVm storeVm = Get.find<StoreVm>();
  final String category;

  CategoryStoreScreen({super.key}) : category = Get.arguments as String {
    storeVm.fetchStoresByCategory(category);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(Get.arguments as String),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          storeVm.fetchStoresByCategory(category);
        },
        child: Obx(
          () =>
              storeVm.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : storeVm.storesByCategory.isEmpty
                  ? const Center(child: Text('Không tìm thấy cửa hàng nào.'))
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: storeVm.storesByCategory.length,
                    itemBuilder: (context, index) {
                      final store = storeVm.storesByCategory[index];

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading:
                            (store.storeImageUrl != null &&
                                    store.storeImageUrl!.isNotEmpty)
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    store.storeImageUrl!,
                                    width: 70,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                  ),
                                )
                                : const Icon(Icons.broken_image, size: 40),
                        title: Text(
                          store.name,
                          style: AppTextStyles.headline.copyWith(fontSize: 16),
                        ),
                        subtitle: Text(
                          store.address,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Get.snackbar(
                            'Click',
                            'Bạn đã chọn cửa hàng: ${store.name}',
                          );
                        },
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
