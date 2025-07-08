import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/seller/revenue/view/revenue_chart.dart';
import 'package:agrimarket/features/seller/revenue/view/revenue_tabledata.dart';
import 'package:agrimarket/features/seller/revenue/viewmodel/revenue_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RevenueScreen extends StatelessWidget {
  const RevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RevenueVm revenueVm = Get.find();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text('Doanh thu', style: AppTextStyles.headline),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child:
            revenueVm.revenueList.isEmpty
                ? Center(child: Text('Chưa có đơn hàng nào', style: AppTextStyles.body.copyWith(color: Colors.grey[600], fontSize: 16)))
                : Column(
                  children: [
                    RevenueTable(revenueList: revenueVm.revenueList),
                    const SizedBox(height: 16),
                    SizedBox(height: 500, child: RevenueChart()),
                  ],
                ),
      ),
    );
  }
}
