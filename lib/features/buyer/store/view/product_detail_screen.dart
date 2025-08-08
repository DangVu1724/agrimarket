import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/features/buyer/cart/viewmodel/cart_vm.dart';
import 'package:uuid/uuid.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  final StoreModel store;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.store,
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
            _buildProductTitle(),
            const SizedBox(height: 8),
            _buildPriceInfo(currencyFormatter),
            const SizedBox(height: 8),
            _buildTotalSold(),
            const SizedBox(height: 8),
            _buildProductDescription(),
            const SizedBox(height: 16),
            _buildStoreInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return GestureDetector(
      onTap: ()=>Get.toNamed(AppRoutes.store, arguments: store),
      child: Container(
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.all(Radius.circular(20))),
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(Iconsax.shop, color: Colors.white,size: 30,),
            SizedBox(width: 20,),
            Text(
              store.name,
              style: AppTextStyles.body.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ],
        ),
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
    if (product.isOnSale) {
      return Row(
      children: [
        Text(
          product.promotionPrice != null
              ? '${currencyFormatter.format(product.promotionPrice)} /${product.unit}'
              : '',
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
    } else {
      return Text(
        '${currencyFormatter.format(product.price)} /${product.unit}',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  Widget _buildTotalSold() {
    return Text(
      'Đã bán: ${product.totalSold}',
      style: AppTextStyles.body.copyWith(fontSize: 16),
    );
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