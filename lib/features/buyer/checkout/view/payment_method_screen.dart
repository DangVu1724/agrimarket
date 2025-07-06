import 'package:agrimarket/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/payment_vm.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> paymentMethods = [
      'Thanh toán khi nhận hàng',
      'Thanh toán qua ZaloPay',
      'Thanh toán qua VNPAY',
      'Thanh toán qua Momo',
    ];
    final PaymentVm paymentVm = Get.find<PaymentVm>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text('Phương thức thanh toán'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: paymentMethods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final method = paymentMethods[index];

          return Obx(() {
            final isSelected = paymentVm.paymentMethod.value == method;
            return GestureDetector(
              onTap:
                  index == 0
                      ? () {
                        if (isSelected) {
                          paymentVm.clearPaymentMethod();
                        } else {
                          paymentVm.setPaymentMethod(method);
                        }
                      }
                      : null,

              child: Opacity(
                opacity: index == 0 ? 1 : 0.5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(method)),
                      const SizedBox(width: 12),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey, width: 2),
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: CustomButton(
            text: 'Áp dụng',
            onPressed: () {
              Get.back();
            },
          ),
        ),
      ),
    );
  }
}
