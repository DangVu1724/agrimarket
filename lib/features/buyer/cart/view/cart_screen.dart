import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:agrimarket/features/buyer/cart/viewmodel/cart_vm.dart';
import 'package:agrimarket/features/buyer/cart/widgets/cartItem.dart';
import 'package:agrimarket/features/buyer/cart/widgets/cart_summary.dart';
import 'package:agrimarket/features/buyer/cart/widgets/checkOutButton.dart';
import 'package:agrimarket/features/buyer/cart/widgets/deleteConfirmationDIalog.dart';
import 'package:agrimarket/features/buyer/cart/widgets/emptyCart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartVm cartVm = Get.find<CartVm>();

  @override
  void initState() {
    super.initState();
    _loadCartAndStores();
  }

  Future<void> _loadCartAndStores() async {
    await cartVm.loadCart();
    final cartData = cartVm.cart.value;
    if (cartData != null) {
      final storeIds = cartData.items.map((e) => e.storeId).toSet();
      for (final id in storeIds) {
        await cartVm.loadStorebyId(id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Giỏ hàng',
          style: AppTextStyles.headline.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await cartVm.loadCart();
        },
        child: Obx(() {
          if (cartVm.isLoadingCart.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }
          final cartData = cartVm.cart.value;
          if (cartData == null || cartData.items.isEmpty) {
            return emptyCart();
          }

          final grouped = cartVm.groupCartByStore(cartData.items);

          return Column(
            children: [
              // Header Summary
              CartSummary(
                cartData: cartData,
                currencyFormatter: currencyFormatter,
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...grouped.entries.map((entry) {
                      final storeId = entry.key;
                      final items = entry.value;
                      final storeName = items.first.storeName;
                      final store = cartVm.store.value[storeId];
                      final storeTotal = items.fold<int>(
                        0,
                            (sum, item) =>
                        sum +
                            ((item.isOnSaleAtAddition == true &&
                                item.promotionPrice != null)
                                ? (item.promotionPrice! * item.quantity.value)
                                .toInt()
                                : (item.priceAtAddition * item.quantity.value)
                                .toInt()),
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Store Header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Store Icon
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.store_rounded,
                                      size: 20,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Store Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          storeName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        if (store != null)
                                          Text(
                                            store.isOpened
                                                ? '🟢 Đang mở cửa'
                                                : '🔴 Đang đóng cửa',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                              store.isOpened
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Checkout Button
                                  checkOutButton(
                                    store: store,
                                    storeId: storeId,
                                  ),
                                ],
                              ),
                            ),

                            // Cart Items
                            ...items
                                .map(
                                  (item) =>
                                  cartItem(context: context, item: item, cartVm: cartVm, currencyFormatter: currencyFormatter),
                            )
                                .toList(),

                            // Store Total
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tổng cửa hàng:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(storeTotal),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

