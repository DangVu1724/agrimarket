import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/store_vm.dart';
import 'package:agrimarket/features/buyer/orders/vỉewmodel/buyer_order_vm.dart';
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
            return _OrderCard(order: order);
          },
        );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Get.to(() => OrderDetailScreen(order: order));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Mã đơn: ${order.orderId}',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Ngày đặt: ${_formatDate(order.createdAt)}',
                      style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Sản phẩm: ${order.items.map((item) => item.name).join(', ')}',
                style: AppTextStyles.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng tiền:', style: AppTextStyles.body.copyWith(color: Colors.grey[600])),
                  Text(
                    _formatPrice(order.totalPrice),
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: Colors.green[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (order.storeName != null && order.storeName!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.store, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Cửa hàng: ${order.storeName}',
                        style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case 'confirmed':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case 'shipping':
        backgroundColor = Colors.yellow[100]!;
        textColor = Colors.yellow[800]!;
        break;
      case 'shipped':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500, color: textColor, fontSize: 12),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(price);
  }
}
