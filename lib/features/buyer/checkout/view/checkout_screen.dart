import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/checkout_vm.dart';
import 'package:agrimarket/features/buyer/cart/viewmodel/cart_vm.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatelessWidget {
  final String storeId;

  const CheckoutScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final CartVm cartVm = Get.find<CartVm>();
    final CheckoutVm checkoutVm = Get.find<CheckoutVm>();
    final BuyerVm vm = Get.find<BuyerVm>();
    final UserVm userVm = Get.find<UserVm>();
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    checkoutVm.getStore(storeId);

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
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Thông tin', style: AppTextStyles.headline.copyWith(fontSize: 16)),
                        GestureDetector(
                          onTap: () {
                            // Get.toNamed(AppRoutes.store, arguments: checkoutVm.store.value);
                          },
                          child: Text(
                            'Chỉnh sửa',
                            style: AppTextStyles.headline.copyWith(color: AppColors.primary, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Column(
                        children: [
                          _buildRowWithPadding('Họ tên', userVm.userName.value),
                          _buildDivider(),
                          _buildRowWithPadding('Số điện thoại', userVm.userPhone.value),
                          _buildDivider(),
                          _buildAddressRowWithLabel('Địa chỉ', vm.defaultAddress!.label ,vm.defaultAddress!.address),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tóm tắt đơn hàng', style: AppTextStyles.headline.copyWith(fontSize: 14)),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.store, arguments: checkoutVm.store.value);
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
                    final totalQuantity = cartVm.getTotalQuantity(storeId);
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
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Tổng cộng (",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: "$totalQuantity sản phẩm",
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                  TextSpan(
                                    text: ") :",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildRowWithPadding(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildAddressRowWithLabel(String title, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90, 
          child: Text(
            title,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}



  Widget _buildDivider() => Container(width: double.infinity, height: 1, color: Colors.grey.shade300);

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
                      '${currencyFormatter.format(item.promotionPrice)} / ${product?.unit}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                  } else ...{
                    Text(
                      "${currencyFormatter.format(item.priceAtAddition)} / ${product?.unit} ",
                      style: const TextStyle(color: Colors.grey),
                    ),
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
