import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/features/buyer/cart/viewmodel/cart_vm.dart';
import 'package:agrimarket/features/buyer/cart/widgets/deleteConfirmationDIalog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class cartItem extends StatelessWidget {
  const cartItem({
    super.key,
    required this.context,
    required this.item,
    required this.cartVm,
    required this.currencyFormatter,
  });

  final BuildContext context;
  final CartItem item;
  final CartVm cartVm;
  final NumberFormat currencyFormatter;

  @override
  Widget build(BuildContext context) {
    final currentPrice =
    (item.isOnSaleAtAddition == true && item.promotionPrice != null)
        ? item.promotionPrice!
        : item.priceAtAddition;
    final totalPrice = currentPrice * item.quantity.value;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final store = cartVm.store.value[item.storeId];
            if (store != null) {
              Get.toNamed(AppRoutes.store, arguments: store);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.productImage,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                          Center(
                            child: Icon(
                              Icons.shopping_bag_rounded,
                              size: 30,
                              color: Colors.grey.shade400,
                            ),
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${currencyFormatter.format(currentPrice)} / ${item
                            .unit}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormatter.format(totalPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quantity Controls & Delete
                Column(
                  children: [
                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          // Decrease Button
                          IconButton(
                            icon: Icon(
                              Icons.remove_rounded,
                              size: 18,
                              color:
                              item.quantity.value > 1
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                            onPressed:
                            item.quantity.value > 1
                                ? () {
                              cartVm.decreaseQuantity(
                                item.productId,
                                item.storeId,
                                item.quantity.value - 1,
                                item,
                              );
                            }
                                : null,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                          // Quantity Display
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              item.quantity.value.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          // Increase Button
                          IconButton(
                            icon: const Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              cartVm.increaseQuantity(
                                item.productId,
                                item.storeId,
                                item.quantity.value + 1,
                              );
                            },
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Delete Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.red.shade600,
                        ),
                        onPressed: () {
                          DeleteConfirmationDialog.show(context, item, cartVm);
                        },
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}