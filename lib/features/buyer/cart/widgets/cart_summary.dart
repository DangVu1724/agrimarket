import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/data/models/cart.dart';

class CartSummary extends StatelessWidget {
  final Cart cartData;
  final NumberFormat currencyFormatter;

  const CartSummary({
    super.key,
    required this.cartData,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final totalItems = cartData.items.fold<int>(0, (sum, item) => sum + item.quantity.value);
    final totalPrice = cartData.items.fold<int>(
      0,
      (sum, item) => sum +
          ((item.isOnSaleAtAddition == true && item.promotionPrice != null)
              ? (item.promotionPrice! * item.quantity.value).toInt()
              : (item.priceAtAddition * item.quantity.value).toInt()),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalItems sản phẩm',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
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
        ],
      ),
    );
  }
}
