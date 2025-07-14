import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/core/widgets/custom_button.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/discount_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DiscountCodeScreen extends StatelessWidget {
  final String storeId;
  final double total;
  const DiscountCodeScreen({super.key, required this.storeId, required this.total});

  @override
  Widget build(BuildContext context) {
    final DiscountVm vm = Get.find<DiscountVm>();
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final formatted = DateFormat('dd/MM/yyyy');

    // Load discount codes when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!vm.hasInitialized.value) {
        vm.fetchDiscountCodes(storeId);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Mã giảm giá')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (vm.isLoadingDiscountCodes.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vm.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lỗi: ${vm.errorMessage.value}'),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: () => vm.fetchDiscountCodes(storeId), child: const Text('Thử lại')),
                    ],
                  ),
                );
              }

              if (vm.discountCodes.isEmpty) {
                return const Center(child: Text('Không có mã giảm giá nào'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: vm.discountCodes.length,
                itemBuilder: (context, index) {
                  final discountCode = vm.discountCodes[index];

                  return Obx(() {
                    final isSelected = vm.selectedDiscountCode.value?.id == discountCode.id;
                    final isValid = discountCode.minOrder <= total;
                    return GestureDetector(
                      onTap: () {
                        if (isValid) {
                          print('Selecting discount code: ${discountCode.code}');
                          vm.selectDiscountCode(discountCode);
                        } else {
                          print('Discount code not valid: ${discountCode.code}');
                          return;
                        }
                      },
                      child: Opacity(
                        opacity: isValid ? 1 : 0.5,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                            color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      discountCode.code,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    if (discountCode.discountType == 'fixed')
                                      Text(
                                        'Giảm ${formatter.format(discountCode.value)} cho đơn hàng từ ${formatter.format(discountCode.minOrder)}',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    if (discountCode.discountType == 'percent')
                                      Text(
                                        'Giảm ${discountCode.value}% cho đơn hàng từ ${formatter.format(discountCode.minOrder)}',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'HSD: ${formatted.format(discountCode.expiredDate)}',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  border: Border.all(color: isSelected ? AppColors.primary : Colors.grey, width: 2),
                                ),
                                child: isSelected ? Icon(Icons.check, color: Colors.white, size: 16) : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
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
