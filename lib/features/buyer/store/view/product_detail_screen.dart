import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/features/buyer/store/viewmodel/cart_vm.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  final StoreModel store;
  final ProductPromotionModel? discount;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.store,
    this.discount,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    final CartVm cartVm = Get.find<CartVm>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(currencyFormatter),
      bottomNavigationBar: _buildBottomBar(cartVm, currencyFormatter),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(200),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (product.imageUrl.isNotEmpty)
            Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
            )
          else
            Container(color: Colors.grey.shade300),
          Container(color: Colors.black.withOpacity(0.4)),
          AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(NumberFormat currencyFormatter) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildStoreInfo(),
            _buildProductTitle(),
            const SizedBox(height: 8),
            _buildPriceInfo(currencyFormatter),
            const SizedBox(height: 8),
            _buildProductDescription(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Text(
      'Cửa hàng: ${store.name}',
      style: AppTextStyles.body.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProductTitle() {
    return Text(
      product.name,
      style: AppTextStyles.headline.copyWith(fontSize: 24),
    );
  }

  Widget _buildPriceInfo(NumberFormat currencyFormatter) {
    final hasDiscount = product.promotion != null && discount?.discountValue != null;
    
    if (!hasDiscount) {
      return Text(
        '${currencyFormatter.format(product.price)} /${product.unit}',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      children: [
        Text(
          _calculateDiscountedPrice(currencyFormatter),
          style: TextStyle(
            fontSize: 16,
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${currencyFormatter.format(product.price)} /${product.unit}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      ],
    );
  }

  String _calculateDiscountedPrice(NumberFormat currencyFormatter) {
    if (discount?.discountType == "percent") {
      return currencyFormatter.format(
        product.price - (product.price * discount!.discountValue) / 100,
      );
    }
    return currencyFormatter.format(product.price - discount!.discountValue);
  }

  Widget _buildProductDescription() {
    return Text(
      'Mô tả: ${product.description}',
      style: AppTextStyles.body.copyWith(fontSize: 16),
    );
  }

  Widget _buildBottomBar(CartVm cartVm, NumberFormat currencyFormatter) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(
        () => Row(
          children: [
            _buildQuantityControls(cartVm),
            const SizedBox(width: 10),
            _buildAddToCartButton(cartVm),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(CartVm cartVm) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (cartVm.itemCount.value > 1) {
              cartVm.itemCount.value--;
            }
          },
        ),
        const SizedBox(width: 5),
        Text(
          cartVm.itemCount.value.toString(),
          style: AppTextStyles.body.copyWith(fontSize: 14),
        ),
        const SizedBox(width: 5),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => cartVm.itemCount.value++,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(CartVm cartVm) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          cartVm.addItem(
            product: product,
            store: store,
            itemCount: cartVm.itemCount.value,
          );
          Get.back();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          'Thêm vào giỏ hàng',
          style: AppTextStyles.button.copyWith(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}