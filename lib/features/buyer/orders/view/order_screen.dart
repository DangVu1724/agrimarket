import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/features/buyer/buyer_vm.dart';
import 'package:agrimarket/features/buyer/orders/view/order_card.dart';
import 'package:agrimarket/features/buyer/orders/viewmodel/buyer_order_vm.dart';
import 'package:agrimarket/features/buyer/orders/view/order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buyerOrderVm = Get.put(BuyerOrderVm());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Đơn hàng',
          style: AppTextStyles.headline.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () {
              buyerOrderVm.loadOrders(Get.find<BuyerVm>().buyerData.value!.uid);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (buyerOrderVm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
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
                    labelColor: Colors.green[700],
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: Colors.green[700],
                    indicatorWeight: 3,
                    labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                    padding: EdgeInsets.zero,
                    indicatorPadding: EdgeInsets.zero,
                    tabs: const [
                      Tab(text: 'Đang chờ'),
                      Tab(text: 'Đã xác nhận'),
                      Tab(text: 'Đang giao'),
                      Tab(text: 'Đã giao'),
                      Tab(text: 'Đã hủy'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildUnconfirmedOrderTab(context, buyerOrderVm),
                    _buildConfirmedOrderTab(context, buyerOrderVm),
                    _buildShippingOrderTab(context, buyerOrderVm),
                    _buildDeliveredOrderTab(context, buyerOrderVm),
                    _buildCancelledOrderTab(context, buyerOrderVm),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUnconfirmedOrderTab(BuildContext context, BuyerOrderVm buyerOrderVm) {
    return _buildOrderList(buyerOrderVm.unconfirmedOrders.toList(), 'Chưa có đơn hàng đang chờ');
  }

  Widget _buildConfirmedOrderTab(BuildContext context, BuyerOrderVm buyerOrderVm) {
    return _buildOrderList(buyerOrderVm.confirmedOrders.toList(), 'Chưa có đơn hàng đã xác nhận');
  }

  Widget _buildShippingOrderTab(BuildContext context, BuyerOrderVm buyerOrderVm) {
    return _buildOrderList(buyerOrderVm.shippedOrders.toList(), 'Chưa có đơn hàng đang giao');
  }

  Widget _buildDeliveredOrderTab(BuildContext context, BuyerOrderVm buyerOrderVm) {
    return _buildOrderList(buyerOrderVm.deliveredOrders.toList(), 'Chưa có đơn hàng đã giao');
  }

  Widget _buildCancelledOrderTab(BuildContext context, BuyerOrderVm buyerOrderVm) {
    return _buildOrderList(buyerOrderVm.cancelledOrders.toList(), 'Chưa có đơn hàng đã hủy');
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
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return BuyerOrderCard(order: order);
          },
        );
  }
}
