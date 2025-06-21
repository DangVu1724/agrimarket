import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/features/seller/product/viewmodel/seller_product_screen_vm.dart';
import 'package:agrimarket/features/seller/promotion/viewmodel/promotion_vm.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDiscountCard extends StatelessWidget {
  final ProductPromotionModel discount;
  final PromotionVm vm = Get.find<PromotionVm>();
  final SellerProductVm productVm = Get.find<SellerProductVm>();

  ProductDiscountCard({super.key, required this.discount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      child: ExpansionTileCard(
        elevation: 2,
        baseColor: const Color.fromARGB(255, 174, 198, 159),
        expandedColor: AppColors.background,
        borderRadius: BorderRadius.circular(12),

        title: Text(
          discount.id,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle:
            discount.discountType == 'percent'
                ? Text(
                  'Giảm ${discount.discountValue}%',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                )
                : Text(
                  'Giảm ${discount.discountValue}k',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        _showAddProductsDialog(context);
                      },
                      icon: const Icon(Icons.add, size: 15),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: AppColors.primary,
                            size: 15,
                          ),
                          onPressed: () {
                            // vm.editProductDiscount(discount.id);
                            Get.snackbar(
                              '',
                              'Chức năng chỉnh sửa chưa được triển khai',
                              snackPosition: SnackPosition.TOP,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 15,
                          ),
                          onPressed: () {
                            Get.defaultDialog(
                              title: 'Xác nhận xoá khuyến mãi',
                              titleStyle: AppTextStyles.headline,
                              content: const Text(
                                'Bạn có chắc muốn xoá khuyến mãi này?',
                                textAlign: TextAlign.center,
                              ),
                              textConfirm: 'Xóa',
                              textCancel: 'Hủy',
                              confirmTextColor: Colors.white,
                              cancelTextColor: AppColors.textPrimary,
                              buttonColor: AppColors.error,
                              onConfirm: () {
                                vm.deleteProductDiscount(discount.id);
                                Get.back();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: discount.productIds.length,
                  itemBuilder: (context, productIndex) {
                    final productId = discount.productIds[productIndex];

                    return FutureBuilder<ProductModel?>(
                      future: vm.getProductById(productId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Text('Không tìm thấy sản phẩm');
                        }
                        final product = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.imageUrl,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        height: 50,
                                        width: 50,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: AppTextStyles.body,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Get.defaultDialog(
                                    title: 'Xác nhận xoá sản phẩm',
                                    titleStyle: AppTextStyles.headline,
                                    content: const Text(
                                      'Bạn có chắc muốn xoá sản phẩm này khỏi khuyến mãi?',
                                      textAlign: TextAlign.center,
                                    ),
                                    textConfirm: 'Xóa',
                                    textCancel: 'Hủy',
                                    confirmTextColor: Colors.white,
                                    cancelTextColor: AppColors.textPrimary,
                                    buttonColor: AppColors.error,
                                    onConfirm: () {
                                      vm.removeProductFromDiscount(
                                        discount.id,
                                        productId,
                                      );
                                      Get.back();
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  size: 14,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProductsDialog(BuildContext context) {
    final selectedProductIds = <String>[].obs;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.background,
            title: Text(
              'Thêm sản phẩm vào khuyến mãi',
              style: AppTextStyles.headline,
            ),
            content: Obx(() {
              final availableProducts = vm.productVm.allProducts;
              if (availableProducts.isEmpty) {
                return const Text('Chưa có sản phẩm nào trong cửa hàng.');
              }

              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableProducts.length,
                  itemBuilder: (context, index) {
                    final product = availableProducts[index];
                    return Obx(
                      () => CheckboxListTile(
                        title: Text(product.name, style: AppTextStyles.body),
                        value: selectedProductIds.contains(product.id),
                        onChanged: (value) {
                          if (value == true) {
                            selectedProductIds.add(product.id);
                          } else {
                            selectedProductIds.remove(product.id);
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            }),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Hủy',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (selectedProductIds.isNotEmpty) {
                    for (final productId in selectedProductIds) {
                      vm.addProductToDiscount(discount.id, productId);
                    }
                    Get.back();
                  } else {
                    Get.snackbar(
                      'Lỗi',
                      'Vui lòng chọn ít nhất một sản phẩm',
                      snackPosition: SnackPosition.TOP,
                    );
                  }
                },
                child: const Text(
                  'Thêm',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }
}
