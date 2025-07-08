import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/product_filter.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/services/seller_store_service.dart';
import 'package:agrimarket/features/seller/product/viewmodel/seller_product_screen_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerProductScreen extends StatelessWidget {
  SellerProductScreen({super.key});

  final SellerProductVm productVm = Get.find<SellerProductVm>();
  final SellerStoreService _sellerStoreService = SellerStoreService();

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
              try {
                Get.toNamed(AppRoutes.sellerCreateProduct);
              } catch (e) {
                print('❌ Error navigating to create product: $e');
                Get.snackbar('Lỗi', 'Không thể mở màn hình tạo sản phẩm');
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        try {
          if (productVm.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productVm.storeModel == null) {
            return const Center(child: Text("Không tìm thấy thông tin cửa hàng."));
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
                    try {
                      if (productVm.storeModel != null) {
                        await _sellerStoreService.getCurrentSellerStore();
                        productVm.clearFilters();
                      }
                    } catch (e) {
                      print('❌ Error refreshing products: $e');
                      Get.snackbar('Lỗi', 'Không thể làm mới dữ liệu');
                    }
                  },
                  child: Obx(() {
                    try {
                      final products = productVm.getFilteredProducts();

                      if (products.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Chưa có sản phẩm nào', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          try {
                            final product = products[index];
                            return _buildProductItem(
                              product: product,
                              onTap: () {
                                try {
                                  Get.toNamed(AppRoutes.sellerProductDetail, arguments: product);
                                } catch (e) {
                                  print('❌ Error navigating to product detail: $e');
                                  Get.snackbar('Lỗi', 'Không thể mở chi tiết sản phẩm');
                                }
                              },
                              onDelete: () {
                                try {
                                  productVm.deleteProduct(product.id);
                                } catch (e) {
                                  print('❌ Error deleting product: $e');
                                  Get.snackbar('Lỗi', 'Không thể xóa sản phẩm');
                                }
                              },
                            );
                          } catch (e) {
                            print('❌ Error building product item at index $index: $e');
                            return const SizedBox.shrink();
                          }
                        },
                      );
                    } catch (e) {
                      print('❌ Error in product list: $e');
                      return const Center(child: Text('Lỗi tải danh sách sản phẩm'));
                    }
                  }),
                ),
              ),
            ],
          );
        } catch (e) {
          print('❌ Error in SellerProductScreen build: $e');
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
                    productVm.fetchProducts();
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

  Widget _buildProductItem({required ProductModel product, VoidCallback? onTap, VoidCallback? onDelete}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(0),
        margin: const EdgeInsets.all(0),
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
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
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
                const SizedBox(width: 15),
                Container(
                  width: 150,
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        '${product.price.toString()} VNĐ / ${product.unit}',
                        style: AppTextStyles.body.copyWith(color: AppColors.primary, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Số lượng: ${product.quantity}',
                        style: AppTextStyles.body.copyWith(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 14), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
