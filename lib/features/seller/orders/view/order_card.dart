import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/features/seller/financial/viewmodel/financial_vm.dart';
import 'package:agrimarket/features/seller/orders/viewmodel/seller_orders_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final CommissionVm commissionVm = Get.put(CommissionVm());

    return Card(
      elevation: 4,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với mã đơn và trạng thái
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long, 
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mã đơn: ${order.orderId}',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey.shade800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusChip(order.status),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Thông tin ngày đặt
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined, 
                         size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(order.createdAt),
                      style: AppTextStyles.body.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Danh sách sản phẩm
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_basket_outlined, 
                             size: 16, color: Colors.grey.shade700),
                        const SizedBox(width: 6),
                        Text('Sản phẩm:', 
                             style: AppTextStyles.body.copyWith(
                               fontWeight: FontWeight.bold,
                               color: Colors.grey.shade700,
                             )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...order.items.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(top: 8, right: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.value.name,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${entry.value.quantity} x ${_formatPrice(entry.value.price)}/${entry.value.unit}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tổng tiền
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng tiền:',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      _formatPrice(order.totalPrice),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Nút hành động
              if (order.status == 'pending') ...[
                _buildActionButtons(
                  confirmText: 'Xác nhận',
                  cancelText: 'Từ chối',
                  onConfirm: () => _updateOrderStatus('confirmed', order),
                  onCancel: () => _updateOrderStatus('cancelled', order),
                ),
              ] else if (order.status == 'confirmed') ...[
                _buildSingleActionButton(
                  text: 'Bắt đầu giao hàng',
                  icon: Icons.local_shipping_outlined,
                  backgroundColor: Colors.orange.shade500,
                  onPressed: () => _updateOrderStatus('shipped', order),
                ),
              ] else if (order.status == 'shipped') ...[
                _buildSingleActionButton(
                  text: 'Xác nhận giao hàng',
                  icon: Icons.check_circle_outline,
                  backgroundColor: AppColors.primary,
                  onPressed: () async {
                    _updateOrderStatus('delivered', order);
                    await commissionVm.updateOrCreateCommissionForDeliveredOrder(order);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons({
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: Text(confirmText, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.shade400),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: Text(cancelText, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleActionButton({
    required String text,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
  IconData icon;

  switch (status) {
    case 'pending':
      backgroundColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.access_time;
      break;
    case 'confirmed':
      backgroundColor = Colors.blue.shade50;
      textColor = Colors.blue.shade800;
      icon = Icons.verified_outlined;
      break;
    case 'shipped':
      backgroundColor = Colors.yellow.shade50;
      textColor = Colors.yellow.shade800;
      icon = Icons.local_shipping;
      break;
    case 'delivered':
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
      icon = Icons.check_circle;
      break;
    case 'cancelled':
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade800;
      icon = Icons.cancel;
      break;
    default:
      backgroundColor = Colors.grey.shade50;
      textColor = Colors.grey.shade800;
      icon = Icons.help_outline;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: textColor.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor),
        const SizedBox(width: 4),
        Text(
          _getStatusText(status),
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
            fontSize: 12,
          ),
        ),
      ],
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