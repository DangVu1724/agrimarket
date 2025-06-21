import 'package:agrimarket/app/routes/app_routes.dart';
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
        title: Text(Get.arguments as String,style: AppTextStyles.headline,),
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
                    itemCount: storeVm.storesByCategory.length,
                    itemBuilder: (context, index) {
                      final store = storeVm.storesByCategory[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                            Get.toNamed(AppRoutes.store, arguments: store.storeId);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  store.storeImageUrl ?? '',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.store, size: 50),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      store.name,
                                      style: AppTextStyles.headline.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      store.address,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 13,
                                      ),
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
                  ),
        ),
      ),
    );
  }
}
