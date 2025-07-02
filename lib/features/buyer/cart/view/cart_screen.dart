import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/features/buyer/cart/viewmodel/cart_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartVm cartVm = Get.find<CartVm>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartVm.loadCart();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng', style: AppTextStyles.headline),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          cartVm.loadCart();
        },
        child: Obx(() {
          if (cartVm.isLoadingCart.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final cartData = cartVm.cart.value;
          if (cartData == null || cartData.items.isEmpty) {
            return Center(child: Text('Giỏ hàng đang trống', style: AppTextStyles.headline));
          }

          final grouped = cartVm.groupCartByStore(cartData.items);

          return ListView(
            children:
                grouped.entries.map((entry) {
                  final storeId = entry.key;
                  final items = entry.value;
                  final storeName = items.first.storeName;

                  return Container(
                    margin: const EdgeInsets.all(6),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên cửa hàng
                        Container(
                          // padding: EdgeInsets.all(12),
                          // decoration: BoxDecoration(
                          //   color: AppColors.primary,
                          //   borderRadius: BorderRadius.circular(12)
                          // ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(storeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                              ElevatedButton.icon(
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.background)),
                                icon: const Icon(Icons.payment, color: AppColors.primary),
                                label: const Text('Thanh toán', style: TextStyle(color: AppColors.primary)),
                                onPressed: () {
                                  Get.toNamed(AppRoutes.checkOut, arguments: {'storeId': storeId});
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Danh sách sản phẩm của cửa hàng này
                        ...items.map((item) => _buildCartItem(item, cartVm)).toList(),

                        const Divider(),
                      ],
                    ),
                  );
                }).toList(),
          );
        }),
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

    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.buyerProductDetail, arguments: {'store': store!.toJson(),'product': product!.toJson()});
      },
      child: Card(
        color: AppColors.background,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    Text(item.productName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    if (item.isOnSaleAtAddition == true && item.promotionPrice != null) ...{
                      Text(
                        '${currencyFormatter.format(item.promotionPrice)} / ${product?.unit ?? ""}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng: ${currencyFormatter.format(item.promotionPrice! * item.quantity.value)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    } else ...{
                      Text(
                        '${currencyFormatter.format(item.priceAtAddition)} / ${product?.unit ?? ""}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng: ${currencyFormatter.format(item.priceAtAddition * item.quantity.value)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    },
                  ],
                ),
              ),

              // Nút điều chỉnh số lượng và xóa
              Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                        onPressed: () {
                          cartVm.decreaseQuantity(item.productId, item.storeId, item.quantity.value - 1, item);
                        },
                      ),
                      Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                        onPressed: () {
                          cartVm.increaseQuantity(item.productId, item.storeId, item.quantity.value + 1);
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      cartVm.removeFromCart(item);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
