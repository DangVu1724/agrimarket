import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/product_filter.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:agrimarket/features/seller/product/viewmodel/seller_product_screen_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerProductScreen extends StatelessWidget {
  SellerProductScreen({super.key});

  final SellerProductVm productVm = Get.find<SellerProductVm>();
  final StoreService _storeService = StoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sản phẩm', style: AppTextStyles.headline),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.toNamed(AppRoutes.sellerCreateProduct);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (productVm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productVm.storeModel == null) {
          return const Center(
            child: Text("Không tìm thấy thông tin cửa hàng."),
          );
        }

        return Column(
          children: [
            ProductFilterWidget(
              searchController: productVm.searchController,
              categories: productVm.categories,
              selectedCategory: productVm.selectedCategory.value,
              onSearchChanged: (query) {
                productVm.searchQuery.value = query;
              },
              onCategoryChanged: (category) {
                productVm.selectedCategory.value = category ?? '';
              },
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (productVm.storeModel != null) {
                    await _storeService.fetchStoreData();
                    productVm.clearFilters();
                  }
                },
                child: Obx(() {
                  final products = productVm.getFilteredProducts();

                  if (products.isEmpty) {
                    return const Center(
                      child: Text("Chưa có sản phẩm nào phù hợp"),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductItem(
                        product: product,
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.sellerProductDetail,
                            arguments: product,
                          );
                        },
                        onDelete: () {
                          Get.defaultDialog(
                            contentPadding: EdgeInsets.all(20),
                            backgroundColor: AppColors.background,
                            title: 'Xác nhận',
                            titleStyle: AppTextStyles.headline.copyWith(
                              color: AppColors.error,
                              fontSize: 28,
                            ),
                            middleText:
                                'Bạn có chắc muốn xóa sản phẩm này không?',
                            textConfirm: 'Xóa',
                            textCancel: 'Hủy',
                            confirmTextColor: Colors.white,
                            cancelTextColor: AppColors.textPrimary,
                            buttonColor: AppColors.error,
                            onConfirm: () {
                              productVm.deleteProduct(product.id);
                              Get.back();
                            },
                            onCancel: () {},
                          );
                        },
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProductItem({
    required ProductModel product,
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.all(0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    height: 100,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15,),
                Container(
                  width: 100,
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.price.toString()} VNĐ / ${product.unit}',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Số lượng: ${product.quantity}',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 14),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
