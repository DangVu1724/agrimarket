import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/custom_button.dart';
import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/checkout_vm.dart';
import 'package:agrimarket/features/buyer/cart/viewmodel/cart_vm.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/discount_vm.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/payment_vm.dart';
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
    final DiscountVm discountVm = Get.find<DiscountVm>();
    final PaymentVm paymentVm = Get.find<PaymentVm>();
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    // Load data when widget builds (only if not already loaded)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!checkoutVm.hasInitialized.value) {
        checkoutVm.getStore(storeId);
      }
      if (!discountVm.hasInitialized.value) {
        discountVm.fetchDiscountCodes(storeId);
      }
      // Always reload payment method to ensure it's up to date
      paymentVm.loadPaymentMethod();
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('Thanh toán', style: AppTextStyles.headline),
            Obx(() {
              if (checkoutVm.isLoadingStore.value) {
                return Text('Đang tải...', style: AppTextStyles.headline.copyWith(fontSize: 14));
              } else if (checkoutVm.errorMessage.value.isNotEmpty) {
                return Text('Lỗi tải dữ liệu', style: AppTextStyles.headline.copyWith(fontSize: 14, color: Colors.red));
              } else {
                return Text(
                  checkoutVm.store.value?.name ?? 'Không xác định',
                  style: AppTextStyles.headline.copyWith(fontSize: 14),
                );
              }
            }),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          userVm.loadUserData();
          final CheckoutVm checkoutVm = Get.find<CheckoutVm>();
          final DiscountVm discountVm = Get.find<DiscountVm>();

          // Retry loading store and discount codes
          await checkoutVm.getStore(storeId);
          await discountVm.fetchDiscountCodes(storeId);
          return;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Obx(
                        () => Container(
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
                              _buildAddressRowWithLabel(
                                'Địa chỉ',
                                vm.defaultAddress!.label,
                                vm.defaultAddress!.address,
                              ),
                            ],
                          ),
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
                      double discountPrice = 0;
                      try {
                        if (discountVm.selectedDiscountCode.value?.discountType == 'fixed') {
                          final discount = discountVm.selectedDiscountCode.value?.value ?? 0;
                          discountPrice = discount;
                        }
                        if (discountVm.selectedDiscountCode.value?.discountType == 'percent') {
                          final discountPercent = discountVm.selectedDiscountCode.value?.value ?? 0;
                          discountPrice = total * discountPercent / 100;
                        }
                      } catch (discountError) {
                        discountPrice = 0;
                      }
                      final finalTotal = total + serviceFee + shippingFee - discountPrice;

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
                          if (discountVm.selectedDiscountCode.value != null) ...{
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Giảm giá:", style: TextStyle(fontSize: 15)),
                                if (discountVm.selectedDiscountCode.value?.discountType == 'fixed')
                                  Text(
                                    '- ${formatter.format(discountVm.selectedDiscountCode.value!.value)}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                if (discountVm.selectedDiscountCode.value?.discountType == 'percent')
                                  Text(
                                    '- ${formatter.format(total * discountVm.selectedDiscountCode.value!.value / 100)}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                              ],
                            ),
                          },
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

                const SizedBox(height: 10),
                Text('Mã giảm giá', style: AppTextStyles.headline.copyWith(fontSize: 14)),
                const SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.discount_outlined, color: AppColors.primary, size: 14),
                  title: Text('Áp dụng mã giảm giá', style: AppTextStyles.headline.copyWith(fontSize: 16)),
                  subtitle: Obx(() {
                    try {
                      return Text(
                        discountVm.hasSelectedDiscountCode
                            ? "Đã áp dụng mã giảm giá ${discountVm.selectedDiscountCodeText ?? ''}"
                            : "Chọn mã giảm giá",
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 14,
                          color: discountVm.hasSelectedDiscountCode ? AppColors.primary : Colors.grey,
                        ),
                      );
                    } catch (e) {
                      return Text(
                        "Chọn mã giảm giá",
                        style: AppTextStyles.headline.copyWith(fontSize: 14, color: Colors.grey),
                      );
                    }
                  }),
                  trailing: Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  onTap: () async {
                    await Get.toNamed(
                      AppRoutes.discountCode,
                      arguments: {'storeId': storeId, 'total': cartVm.getTotalPriceByStore(storeId)},
                    );
                    // Reload discount codes when returning from discount screen
                    discountVm.fetchDiscountCodes(storeId);
                  },
                ),
                const SizedBox(height: 10),
                Text('Phương thức thanh toán', style: AppTextStyles.headline.copyWith(fontSize: 14)),
                const SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.payment, color: AppColors.primary, size: 14),
                  title: Text('Phương thức thanh toán', style: AppTextStyles.headline.copyWith(fontSize: 16)),
                  subtitle: Obx(() {
                    try {
                      return Text(
                        paymentVm.hasPaymentMethod ? paymentVm.paymentMethod.value : "Chọn phương thức thanh toán",
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 14,
                          color: paymentVm.hasPaymentMethod ? AppColors.primary : Colors.grey,
                        ),
                      );
                    } catch (e) {
                      return Text(
                        "Chọn phương thức thanh toán",
                        style: AppTextStyles.headline.copyWith(fontSize: 14, color: Colors.grey),
                      );
                    }
                  }),
                  trailing: Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  onTap: () async {
                    await Get.toNamed(AppRoutes.paymentMethod);
                    // Reload payment method when returning from payment screen
                    paymentVm.loadPaymentMethod();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: Obx(
            () => CustomButton(
              text: checkoutVm.isCreatingOrder.value ? 'Đang tạo đơn hàng...' : 'Xác nhận thanh toán',
              onPressed: () async {
                // Kiểm tra validation trước khi hiển thị loading
                final CartVm cartVm = Get.find<CartVm>();
                final PaymentVm paymentVm = Get.find<PaymentVm>();
                final BuyerVm buyerVm = Get.find<BuyerVm>();
                final CheckoutVm checkoutVm = Get.find<CheckoutVm>();

                // Validate trước khi hiển thị loading
                if (!paymentVm.hasPaymentMethod) {
                  Get.snackbar('Lỗi', 'Vui lòng chọn phương thức thanh toán');
                  return;
                }

                if (buyerVm.defaultAddress == null) {
                  Get.snackbar('Lỗi', 'Vui lòng chọn địa chỉ giao hàng');
                  return;
                }

                if (userVm.userPhone.value.isEmpty) {
                  Get.snackbar('Lỗi', 'Vui lòng cập nhật số điện thoại');
                  return;
                }

                if (checkoutVm.auth.currentUser?.uid == null) {
                  Get.snackbar('Lỗi', 'Vui lòng đăng nhập lại');
                  return;
                }

                final items = cartVm.cart.value?.items.where((item) => item.storeId == storeId).toList() ?? [];
                if (items.isEmpty) {
                  Get.snackbar('Lỗi', 'Không có sản phẩm nào trong giỏ hàng');
                  return;
                }

                // Chỉ hiển thị loading khi validation pass
                Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                await _handleOrderCreation();
                Get.back(); // Đóng loading dialog
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowWithPadding(String title, String value) {
    final UserVm userVm = Get.find<UserVm>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          GestureDetector(
            onTap: () async {
              await Get.toNamed(AppRoutes.buyerAccount);
              userVm.loadUserData();
            },
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
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
          SizedBox(width: 90, child: Text(title, style: TextStyle(color: Colors.grey))),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.buyerAddress);
              },
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
          ),
        ],
      ),
    );
  }

  Future<void> _handleOrderCreation() async {
    final CartVm cartVm = Get.find<CartVm>();
    final CheckoutVm checkoutVm = Get.find<CheckoutVm>();
    final PaymentVm paymentVm = Get.find<PaymentVm>();
    final DiscountVm discountVm = Get.find<DiscountVm>();
    final BuyerVm buyerVm = Get.find<BuyerVm>();
    final UserVm userVm = Get.find<UserVm>();
    try {
      // Validation đã được thực hiện ở trên, chỉ cần lấy data
      final items = cartVm.cart.value?.items.where((item) => item.storeId == storeId).toList() ?? [];

      // Calculate discount
      double discountPrice = 0;
      String? discountCodeId;
      if (discountVm.hasSelectedDiscountCode) {
        final selectedCode = discountVm.selectedDiscountCode.value!;
        discountCodeId = selectedCode.id;

        if (selectedCode.discountType == 'fixed') {
          discountPrice = selectedCode.value;
        } else if (selectedCode.discountType == 'percent') {
          final total = cartVm.getTotalPriceByStore(storeId);
          discountPrice = total * selectedCode.value / 100;
        }
      }

      // Create order
      final orderId = await checkoutVm.createOrder(
        storeId: storeId,
        storeName: checkoutVm.store.value?.name ?? '',
        buyerName: userVm.userName.value,
        buyerPhone: userVm.userPhone.value,
        items: items,
        paymentMethod: paymentVm.paymentMethod.value,
        deliveryAddress: buyerVm.defaultAddress!.address,
        discountCodeId: discountCodeId,
        discountPrice: discountPrice,
        isPaid: paymentVm.paymentMethod.value == 'Thanh toán khi nhận hàng' ? false : true,
        isCommissionPaid: paymentVm.paymentMethod.value == 'Thanh toán khi nhận hàng' ? false : true,
      );

      if (orderId != null) {
        try {
          await cartVm.removeItemsByStoreId(storeId);

          discountVm.clearSelectedDiscountCode();

          paymentVm.clearPaymentMethod();
        } catch (clearError) {}
        Get.offAllNamed(AppRoutes.buyerHome);
      }
    } catch (e) {
      // Handle error silently or show snackbar if needed
    }
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
                      '${currencyFormatter.format(item.priceAtAddition)} / ${item.unit} ',
                      style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currencyFormatter.format(item.promotionPrice)} / ${item.unit}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  } else ...{
                    Text(
                      "${currencyFormatter.format(item.priceAtAddition)} / ${item.unit} ",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  },
                ],
              ),
            ),

            Text('x${item.quantity.value.toString()}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
