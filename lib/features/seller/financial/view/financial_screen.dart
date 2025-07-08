import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/seller/financial/viewmodel/financial_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CommissionScreen extends StatelessWidget {
  const CommissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CommissionVm commissionVm = Get.put(CommissionVm());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text('Tài chính', style: AppTextStyles.headline),
        actions: [
          IconButton(
            onPressed: () {
              print('storeId: ${commissionVm.sellerHomeVm.store.value!.storeId}');
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await commissionVm.getCommission();
          await commissionVm.getCommissionHistory(commissionVm.sellerHomeVm.store.value!.storeId);
        },
        child: Obx(() {
          if (commissionVm.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                      padding: EdgeInsets.zero,
                      indicatorPadding: EdgeInsets.zero,
                      tabs: [Tab(text: 'Chưa thanh toán'), Tab(text: 'Lịch sử thanh toán')],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      commissionVm.commissionList.isEmpty
                          ? const Center(child: Text('Chưa có đơn hàng nào'))
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shrinkWrap: true,
                            itemCount: commissionVm.commissionList.length,
                            itemBuilder: (context, index) {
                              final commission = commissionVm.commissionList[index];
                              return Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Thông tin bên trái
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ngày: ${DateFormat('dd/MM/yyyy').format(commission.orderDate)}',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Hoa hồng: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(commission.commissionAmount)}',
                                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                                          ),
                                        ],
                                      ),

                                      // Nút thanh toán bên phải
                                      IconButton(
                                        onPressed: () {
                                          Get.dialog(
                                            AlertDialog(
                                              backgroundColor: AppColors.background,
                                              title: const Text('Xác nhận'),
                                              content: const Text(
                                                'Bạn có chắc chắn muốn thanh toán commission này không?',
                                              ),
                                              actions: [
                                                TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
                                                TextButton(
                                                  onPressed: () {
                                                    Get.back();
                                                    commissionVm.createCommission(
                                                      commission.commissionId,
                                                      commission.storeId,
                                                      commission.storeName,
                                                      commission.orderAmount,
                                                      commission.commissionAmount,
                                                      'waiting',
                                                      commission.orderIds,
                                                      commission.orderDate,
                                                      commission.dueDate,
                                                      commission.createdAt,
                                                      commission.updatedAt,
                                                    );
                                                  },
                                                  child: const Text('Thanh toán'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.payment, color: Colors.green),
                                        tooltip: 'Thanh toán',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                      commissionVm.commissionHistoryList.isEmpty
                          ? const Center(child: Text('Chưa có lịch sử thanh toán'))
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shrinkWrap: true,
                            itemCount: commissionVm.commissionHistoryList.length,
                            itemBuilder: (context, index) {
                              final commission = commissionVm.commissionHistoryList[index];
                              return ListTile(
                                title: Text(DateFormat('dd/MM/yyyy').format(commission.orderDate)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'vi_VN',
                                        symbol: '₫',
                                        decimalDigits: 0,
                                      ).format(commission.commissionAmount),
                                    ),
                                    Text(
                                      'Trạng thái: ${commission.statusText}',
                                      style: TextStyle(
                                        color: commission.status == 'paid' ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
