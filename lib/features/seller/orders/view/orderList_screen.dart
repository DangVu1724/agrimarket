import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/features/seller/orders/view/order_card.dart';
import 'package:agrimarket/features/seller/orders/viewmodel/seller_orders_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderlistScreen extends StatelessWidget {
  const OrderlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SellerOrdersVm vm = Get.put(SellerOrdersVm());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Danh sách đơn hàng', style: AppTextStyles.headline),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => vm.refreshData()),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Stack(children: [IconButton(icon: const Icon(Icons.notifications), onPressed: () {})]),
          ),
        ],
      ),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi: ${vm.errorMessage.value}'),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => vm.refreshData(), child: const Text('Thử lại')),
              ],
            ),
          );
        }

        if (vm.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Chưa có đơn hàng nào', style: AppTextStyles.body.copyWith(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
          );
        }

        return DefaultTabController(
          length: 5,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                    padding: EdgeInsets.zero,
                    indicatorPadding: EdgeInsets.zero,
                    tabs: [
                      Tab(text: 'Chờ xác nhận (${vm.getPendingOrders().length})'),
                      Tab(text: 'Đã xác nhận (${vm.getConfirmedOrders().length})'),
                      Tab(text: 'Đang giao (${vm.getShippedOrders().length})'),
                      Tab(text: 'Đã giao (${vm.getDeliveredOrders().length})'),
                      Tab(text: 'Đã hủy (${vm.getCancelledOrders().length})'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildOrderList(vm.getPendingOrders(), 'Chưa có đơn hàng chờ xác nhận'),
                    _buildOrderList(vm.getConfirmedOrders(), 'Chưa có đơn hàng đã xác nhận'),
                    _buildOrderList(vm.getShippedOrders(), 'Chưa có đơn hàng đang giao'),
                    _buildOrderList(vm.getDeliveredOrders(), 'Chưa có đơn hàng đã giao'),
                    _buildOrderList(vm.getCancelledOrders(), 'Chưa có đơn hàng đã hủy'),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, String emptyMessage) {
    return orders.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(emptyMessage, style: AppTextStyles.body.copyWith(color: Colors.grey[600], fontSize: 16)),
            ],
          ),
        )
        : RefreshIndicator(
          onRefresh: () async {
            final vm = Get.find<SellerOrdersVm>();
            await vm.refreshData();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(order: order);
            },
          ),
        );
  }
}
