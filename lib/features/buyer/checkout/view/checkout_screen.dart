import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/checkout_vm.dart';
import 'package:agrimarket/features/buyer/cart/viewmodel/cart_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatelessWidget {
  final String storeId;

  const CheckoutScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final CartVm cartVm = Get.find<CartVm>();
    final store = cartVm.store.value;
    final CheckoutVm checkoutVm = Get.find<CheckoutVm>();
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh toán', style: AppTextStyles.headline),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tóm tắt đơn hàng', style: AppTextStyles.headline.copyWith(fontSize: 14)),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.store, arguments: store);
                    },
                    child: Text(
                      'Thêm món',
                      style: AppTextStyles.headline.copyWith(color: AppColors.primary, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Obx(() {
                final items = cartVm.cart.value?.items.where((item) => item.storeId == storeId).toList() ?? [];
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildCartItem(item, cartVm);
                  },
                );
              }),
              const SizedBox(height: 10),
              Column(
                children: [
                  Obx(() {
                    final total = cartVm.getTotalPriceByStore(storeId);
                    // final discount = cartVm.getTotalDiscountByStore(storeId);
                    final serviceFee = 5000;
                    final shippingFee = 20000;
                    final finalTotal = total + serviceFee + shippingFee;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Tạm tính:", style: TextStyle(fontSize: 15)),
                            Text(formatter.format(total), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        // if (discount > 0)
                        //   Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       const Text("Giảm giá:", style: TextStyle(fontSize: 15)),
                        //       Text('- ${formatter.format(discount)}', style: const TextStyle(color: Colors.red)),
                        //     ],
                        //   ),
                        // const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Phí dịch vụ:", style: TextStyle(fontSize: 15)),
                            Text(
                              formatter.format(serviceFee),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Phí giao hàng:", style: TextStyle(fontSize: 15)),
                            Text(
                              formatter.format(shippingFee),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Tổng cộng:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              formatter.format(finalTotal),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartVm cartVm) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartVm.loadStorebyId(item.storeId);
      cartVm.loadProductbyId(item.productId);
    });

    final store = cartVm.store.value;
    final product = cartVm.product.value;

    return Card(
      color: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh sản phẩm
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.productImage,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.shopping_cart, size: 40),
              ),
            ),
            const SizedBox(width: 12),

            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  if (item.isOnSaleAtAddition != null && item.isOnSaleAtAddition!) ...{
                    Text(
                      '${currencyFormatter.format(item.promotionPrice)} / ${product!.unit}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                  } else ...{
                    Text(currencyFormatter.format(item.priceAtAddition), style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                  },
                ],
              ),
            ),

            // Nút điều chỉnh số lượng và xóa
            Column(
              children: [
                Obx(
                  () => Text('x${item.quantity.value.toString()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                      onPressed: () {
                        cartVm.decreaseQuantity(item.productId, item.storeId, item.quantity.value - 1, item);
                      },
                    ),
                    Obx(
                      () => Text(
                        '${item.quantity.value.toString()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      onPressed: () {
                        cartVm.increaseQuantity(item.productId, item.storeId, item.quantity.value + 1);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
