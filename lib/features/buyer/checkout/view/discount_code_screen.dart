import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/core/widgets/custom_button.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/discount_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DiscountCodeScreen extends StatefulWidget {
  final String storeId;
  final double total;
  const DiscountCodeScreen({super.key, required this.storeId, required this.total});

  @override
  State<DiscountCodeScreen> createState() => _DiscountCodeScreenState();
}

class _DiscountCodeScreenState extends State<DiscountCodeScreen> {
  late final DiscountVm vm;
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  final dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    vm = Get.find<DiscountVm>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.fetchDiscountCodes(widget.storeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khuyến mãi')),
      body: Obx(() {
        if (vm.isLoadingDiscountCodes.value || vm.isLoadingVouchers.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi: ${vm.errorMessage.value}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    vm.fetchDiscountCodes(widget.storeId);
                    vm.fetchVouchers();
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final now = DateTime.now();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Voucher", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            if (vm.vouchers.isEmpty)
              const Text("Không có voucher khả dụng")
            else
              ...vm.vouchers.map((voucher) {
                final isSelected = vm.selectedVoucher.value == voucher;
                final quantity = voucher.count;
                return GestureDetector(
                  onTap: () => vm.selectVoucher(voucher),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      ),
                      color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(voucher.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  if (quantity > 1) const SizedBox(width: 6),
                                  if (quantity > 1) Text("x$quantity", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                voucher.discountType == 'fixed'
                                    ? 'Giảm ${formatter.format(voucher.discountValue)} (đơn từ ${formatter.format(voucher.minOrder)})'
                                    : 'Giảm ${voucher.discountValue}% (đơn từ ${formatter.format(voucher.minOrder)})',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text('HSD: ${dateFormatter.format(voucher.endDate)}', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              }).toList(),

            const SizedBox(height: 24),

            Text("Mã giảm giá", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            if (vm.discountCodes.isEmpty)
              const Text("Không có mã giảm giá khả dụng")
            else
              ...vm.discountCodes.map((discountCode) {
                final isSelected = vm.selectedDiscountCode.value?.id == discountCode.id;
                final isValid = discountCode.minOrder <= widget.total && discountCode.expiredDate.isAfter(now);

                return GestureDetector(
                  onTap: () {
                    if (isValid) vm.selectDiscountCode(discountCode);
                  },
                  child: Opacity(
                    opacity: isValid ? 1 : 0.5,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        ),
                        color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(discountCode.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  discountCode.discountType == 'fixed'
                                      ? 'Giảm ${formatter.format(discountCode.value)} (đơn từ ${formatter.format(discountCode.minOrder)})'
                                      : 'Giảm ${discountCode.value}% (đơn từ ${formatter.format(discountCode.minOrder)})',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text('HSD: ${dateFormatter.format(discountCode.expiredDate)}', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                          if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: CustomButton(
            text: 'Áp dụng',
            onPressed: () {
              
              Get.back(result: {
                'voucher': vm.selectedVoucher.value,
                'discount': vm.selectedDiscountCode.value,
              });
            },
          ),
        ),
      ),
    );
  }
}
