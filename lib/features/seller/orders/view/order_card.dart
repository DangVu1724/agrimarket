import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/features/seller/orders/viewmodel/seller_orders_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sản phẩm:', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...order.items.map(
                  (item) => Text(
                    '- ${item.name} (${item.quantity} x ${_formatPrice(item.price)}/${item.unit})',
                    style: AppTextStyles.body.copyWith(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng tiền:', style: AppTextStyles.body.copyWith(color: Colors.grey[600])),
                Text(
                  _formatPrice(order.totalPrice),
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (order.status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus('confirmed', order),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Xác nhận'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus('cancelled', order),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text('Từ chối'),
                    ),
                  ),
                ],
              ),
            ] else if (order.status == 'confirmed') ...[
              ElevatedButton(
                onPressed: () => _updateOrderStatus('shipped', order),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[100], foregroundColor: Colors.white),
                child: const Text('Bắt đầu giao hàng'),
              ),
            ] else if (order.status == 'shipped') ...[
              ElevatedButton(
                onPressed: () => _updateOrderStatus('delivered', order),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Giao hàng thành công'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void _updateOrderStatus(String newStatus, OrderModel order) {
  final vm = Get.find<SellerOrdersVm>();
  vm.updateOrderStatus(order.orderId, newStatus);
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
    case 'shipped':
      backgroundColor = Colors.yellow[100]!;
      textColor = Colors.yellow[800]!;
      break;
    case 'delivered':
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
      _getStatusText(status),
      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500, color: textColor, fontSize: 12),
    ),
  );
}

String _getStatusText(String status) {
  switch (status) {
    case 'pending':
      return 'Chờ xác nhận';
    case 'confirmed':
      return 'Đã xác nhận';
    case 'shipped':
      return 'Đang giao';
    case 'delivered':
      return 'Đã giao';
    case 'cancelled':
      return 'Đã hủy';
    default:
      return 'Không xác định';
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}

String _formatPrice(double price) {
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  return formatter.format(price);
}
