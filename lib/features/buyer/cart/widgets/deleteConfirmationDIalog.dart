import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/features/buyer/cart/viewmodel/cart_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class DeleteConfirmationDialog {
  static void show(BuildContext context, CartItem item, CartVm cartVm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Xóa sản phẩm',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bạn có chắc muốn xóa "${item.productName}" khỏi giỏ hàng?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              cartVm.removeFromCart(item);
              Get.back();
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
