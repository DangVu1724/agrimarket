import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/utils/toast_utlis.dart';
import 'package:agrimarket/data/models/vouchers_catalog.dart';
import 'package:agrimarket/data/models/user_vouchers.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/profile/viewmodel/voucher_vm.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final voucherVm = Get.put(VoucherVm());
    final BuyerVm buyerVm = Get.find<BuyerVm>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Voucher", style: AppTextStyles.headline),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Obx(
                  () => Text(
                    buyerVm.userPoints.value != null ? "Điểm: ${buyerVm.userPoints.value}" : "Đang tải...",
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: Colors.orange[300]),
                  ),
                ),
              ),
            ),
          ],

          bottom: const TabBar(tabs: [Tab(text: "Khả dụng"), Tab(text: "Đã đổi")]),
        ),
        body: TabBarView(
          children: [
            VoucherList(showUserVoucher: false, vm: voucherVm),
            VoucherList(showUserVoucher: true, vm: voucherVm),
          ],
        ),
      ),
    );
  }
}

class VoucherList extends StatelessWidget {
  final bool showUserVoucher;
  final VoucherVm vm;
  const VoucherList({super.key, required this.showUserVoucher, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (showUserVoucher && vm.userVouchers.isEmpty) {
        return const Center(child: Text("Bạn chưa đổi voucher nào"));
      }
      if (!showUserVoucher && vm.vouchers.isEmpty) {
        return const Center(child: Text("Không có voucher khả dụng"));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: showUserVoucher ? vm.userVouchers.length : vm.vouchers.length,
        itemBuilder: (context, index) {
          if (showUserVoucher) {
            final UserVoucherModel userVc = vm.userVouchers[index];
            return _buildUserVoucherCard(userVc);
          } else {
            final VoucherModel v = vm.vouchers[index];
            return _buildVoucherCard(v);
          }
        },
      );
    });
  }

  Widget _buildVoucherCard(VoucherModel v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CouponCard(
        height: 161,
        backgroundColor: Colors.orange.withOpacity(0.1),
        curveAxis: Axis.vertical,
        borderRadius: 16,
        firstChild: Container(
          width: 60,
          color: Colors.orange,
          child: const Center(
            child: Text("VOUCHER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        secondChild: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(v.code, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(v.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text("Số lượng: ${v.usageLimit}", maxLines: 2, overflow: TextOverflow.ellipsis),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Points: ${v.pointsRequired} ",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      Text("Hiệu lực: ${v.validDays} ngày", style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed:
                        v.usageLimit == 0
                            ? null 
                            : () async {
                              final result = await vm.redeemVoucher(v.id);

                              if (result?['success'] == true) {
                                showSuccessToast("Đổi voucher thành công");
                              } else {
                                showErrorToast(result?['message'] ?? "Đổi voucher thất bại");
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: v.usageLimit == 0 ? Colors.grey : Colors.orange, 
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      v.usageLimit == 0 ? "Hết" : "Đổi ngay",
                      style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserVoucherCard(UserVoucherModel userVc) {
    return FutureBuilder<VoucherModel?>(
      future: vm.getVoucherDetail(userVc),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final VoucherModel v = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CouponCard(
            height: 120,
            backgroundColor: Colors.blue.withOpacity(0.1),
            curveAxis: Axis.vertical,
            borderRadius: 16,
            firstChild: Container(
              width: 60,
              color: Colors.blue,
              child: const Center(
                child: Text("My Voucher", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            secondChild: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(v.code, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Text("x${userVc.count}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(v.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "HSD: ${userVc.endDate.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(color: Colors.red),
                      ),
                      Text(userVc.status, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
