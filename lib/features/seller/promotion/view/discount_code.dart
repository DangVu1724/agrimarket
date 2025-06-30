import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/dialog_promotion.dart';
import 'package:agrimarket/data/models/discount_code.dart';
import 'package:agrimarket/features/seller/promotion/viewmodel/promotion_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscountCodeCard extends StatelessWidget {
  final DiscountCodeModel code;
  final PromotionVm vm = Get.find<PromotionVm>();

  DiscountCodeCard({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.sell),
        title: Text('Mã: ${code.code}', style: AppTextStyles.headline.copyWith(fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (code.discountType == 'percent')
                ? Text('Giảm ${code.value}% cho đơn từ ${code.minOrder.toStringAsFixed(0)}đ')
                : Text('Giảm ${code.value}k cho đơn từ ${code.minOrder.toStringAsFixed(0)}đ'),
            Text('HSD: đến ${code.expiredDate.toLocal().toString().split(' ')[0]}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              showDialog(context: context, builder: (_) => DialogPromotion(type: 'code', discountCodeModel: code));
            } else if (value == 'delete') {
              vm.deleteDiscountCode(code.id);
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                const PopupMenuItem(value: 'delete', child: Text('Xoá')),
              ],
        ),
      ),
    );
  }
}
