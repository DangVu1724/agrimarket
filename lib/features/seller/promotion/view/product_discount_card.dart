import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/dialog_promotion.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/features/seller/promotion/viewmodel/promotion_vm.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDiscountCard extends StatelessWidget {
  final ProductPromotionModel discount;
  final void Function() onDelete;
  final void Function(String) onRemoveProduct;
  final void Function(List<String>) onAddProducts;

  const ProductDiscountCard({
    super.key,
    required this.discount,
    required this.onDelete,
    required this.onRemoveProduct,
    required this.onAddProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('discount_card_${discount.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTileCard(
        key: Key('discount_card_${discount.id}'),

        elevation: 2,
        baseColor: const Color.fromARGB(255, 174, 198, 159),
        expandedColor: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        initiallyExpanded: false,
        children: [_buildExpandedContent(context)],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Khuyến mãi ${discount.id}',
      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      discount.discountType == 'percent' ? 'Giảm ${discount.discountValue}%' : 'Giảm ${discount.discountValue}k',
      style: AppTextStyles.body.copyWith(color: Colors.grey.shade600, fontSize: 14),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildActionButtons(context), const SizedBox(height: 8), _buildProductList(context)],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _showAddProductsDialog(context),
          icon: const Icon(Icons.add, size: 15),
          tooltip: 'Thêm sản phẩm',
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary, size: 15),
              onPressed: () {
                showDialog(context: context, builder: (_) => DialogPromotion(type: 'product',productPromotionModel: discount,));
              },
              tooltip: 'Chỉnh sửa',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 15),
              onPressed: _showDeleteConfirmation,
              tooltip: 'Xóa khuyến mãi',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductList(BuildContext context) {
    final promotionVm = Get.find<PromotionVm>();
    final products = promotionVm.getProductsByIds(discount.productIds, discount.storeId);

    if (products.isEmpty) {
      return const Center(child: Text('Chưa có sản phẩm nào trong khuyến mãi'));
    }

    return ListView.builder(
      key: Key('discount_card_${discount.id}'),

      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductItem(product);
      },
    );
  }

  Widget _buildProductItem(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _buildProductImage(product),
          const SizedBox(width: 12),
          Expanded(child: Text(product.name, style: AppTextStyles.body, overflow: TextOverflow.ellipsis, maxLines: 1)),
          IconButton(
            onPressed: () => _showRemoveProductConfirmation(product.id),
            icon: const Icon(Icons.delete, size: 14, color: AppColors.error),
            tooltip: 'Xóa khỏi khuyến mãi',
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(ProductModel product) {
    return ClipRRect(
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
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 50,
            width: 50,
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    Get.defaultDialog(
      title: 'Xác nhận xoá khuyến mãi',
      titleStyle: AppTextStyles.headline,
      content: const Text('Bạn có chắc muốn xoá khuyến mãi này?', textAlign: TextAlign.center),
      confirm: _buildDialogButton('Xóa', () async {
        onDelete();
        Get.back();
      }, AppColors.error),
      cancel: _buildDialogButton('Hủy', () async => Get.back(), const Color.fromARGB(255, 255, 255, 255)),
    );
  }

  void _showRemoveProductConfirmation(String productId) {
    Get.defaultDialog(
      title: 'Xác nhận xoá sản phẩm',
      titleStyle: AppTextStyles.headline,
      content: const Text('Bạn có chắc muốn xoá sản phẩm này khỏi khuyến mãi?', textAlign: TextAlign.center),
      confirm: _buildDialogButton('Xóa', () {
        onRemoveProduct(productId);
        Get.back();
        return Future.value();
      }, AppColors.error),
      cancel: _buildDialogButton('Hủy', () async => Get.back(), const Color.fromARGB(255, 255, 255, 255)),
    );
  }

  Widget _buildDialogButton(String text, Future<void> Function()? onPressed, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: onPressed,
      child: Text(text),
    );
  }

  void _showAddProductsDialog(BuildContext context) {
    final promotionVm = Get.find<PromotionVm>();
    final availableProducts = promotionVm.getAvailableProductsForDiscount(discount.id, discount.storeId);

    if (availableProducts.isEmpty) {
      Get.snackbar('Thông báo', 'Tất cả sản phẩm đã được thêm vào khuyến mãi', snackPosition: SnackPosition.TOP);
      return;
    }

    final selectedProductIds = <String>[].obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('Thêm sản phẩm vào khuyến mãi', style: AppTextStyles.headline),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableProducts.length,
                itemBuilder: (context, index) {
                  final product = availableProducts[index];
                  return CheckboxListTile(
                    title: Text(product.name, style: AppTextStyles.body),
                    value: selectedProductIds.contains(product.id),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedProductIds.add(product.id);
                        } else {
                          selectedProductIds.remove(product.id);
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: AppColors.error))),
          TextButton(
            onPressed: () {
              if (selectedProductIds.isEmpty) {
                Get.snackbar('Lỗi', 'Vui lòng chọn ít nhất một sản phẩm', snackPosition: SnackPosition.TOP);
                return;
              }
              onAddProducts(selectedProductIds);
              Get.back();
            },
            child: const Text('Thêm', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
