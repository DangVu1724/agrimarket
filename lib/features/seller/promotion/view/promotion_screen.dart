import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/dialog_promotion.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:agrimarket/features/seller/promotion/view/discount_code.dart';
import 'package:agrimarket/features/seller/promotion/view/product_discount_card.dart';
import 'package:agrimarket/features/seller/promotion/viewmodel/promotion_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerPromotionScreen extends StatelessWidget {
  final PromotionVm promotionVm = Get.put(PromotionVm());
  final SellerHomeVm sellerHomeVm = Get.find<SellerHomeVm>();

  @override
  Widget build(BuildContext context) {
    promotionVm.loadAllPromotions(sellerHomeVm.store.value!.storeId);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Khuyến mãi của tôi', style: AppTextStyles.headline),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              tabs: [Tab(text: 'Giảm giá sản phẩm'), Tab(text: 'Mã giảm giá')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildProductDiscountsTab(),
                  _buildDiscountCodesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateOptionDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateOptionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Tạo khuyến mãi', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.percent, color: Colors.green),
            title: const Text('Tạo mã giảm giá'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => DialogPromotion(type: 'code'),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.local_offer, color: Colors.orange),
            title: const Text('Tạo giảm giá sản phẩm'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => DialogPromotion(type: 'product'),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        )
      ],
    ),
  );
}


  Widget _buildProductDiscountsTab() {
    return Obx(() {
      final list = promotionVm.productDiscounts;
      if (promotionVm.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (list.value.isEmpty) {
        return const Center(child: Text('Chưa có giảm giá sản phẩm nào.'));
      }
      return ListView.builder(
        itemCount: list.value.length,
        itemBuilder: (context, index) {
          final item = list.value[index];
          return ProductDiscountCard(
            discount: item,
            onDelete: () => promotionVm.deleteProductDiscount(item.id),
            onRemoveProduct:
                (productId) =>
                    promotionVm.removeProductFromDiscount(item.id, productId),
            onAddProducts: (productIds) {
              for (final id in productIds) {
                promotionVm.addProductToDiscount(item.id, id);
              }
            },
          );
        },
      );
    });
  }

  Widget _buildDiscountCodesTab() {
    return Obx(() {
      final list = promotionVm.discountCodes;
      if (promotionVm.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (list.value.isEmpty) {
        return const Center(child: Text('Chưa có mã giảm giá nào.'));
      }
      return ListView.builder(
        itemCount: list.value.length,
        itemBuilder: (context, index) {
          final code = list.value[index];
          return DiscountCodeCard(code: code);
        },
      );
    });
  }
}
