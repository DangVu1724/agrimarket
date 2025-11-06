import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class checkOutButton extends StatelessWidget {
  const checkOutButton({
    super.key,
    required this.store,
    required this.storeId,
  });

  final StoreModel? store;
  final String storeId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: store?.isOpened == true ? AppColors.primary : Colors.grey.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: store?.isOpened == true
            ? () {
          Get.toNamed(AppRoutes.checkOut, arguments: storeId);
        }
            : null,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payment_rounded, size: 16),
            SizedBox(width: 6),
            Text(
              'Thanh toán',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}