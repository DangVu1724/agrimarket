import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/features/buyer/orders/view/order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BuyerOrderCard extends StatelessWidget {
  final OrderModel order;

  const BuyerOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => OrderDetailScreen(order: order));
        },
        borderRadius: BorderRadius.circular(16),
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
                
                // Thông tin cửa hàng
                if (order.storeName != null && order.storeName!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.store_outlined, 
                           size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.storeName!,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                
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
                          Text('Sản phẩm đã đặt', 
                               style: AppTextStyles.body.copyWith(
                                 fontWeight: FontWeight.bold,
                                 color: Colors.grey.shade700,
                               )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...order.items.take(2).map(
                        (item) => Padding(
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
                                      item.name,
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade800,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.quantity} x ${_formatPrice(item.price)}/${item.unit}',
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
                      if (order.items.length > 2) ...[
                        const SizedBox(height: 4),
                        Text(
                          'và ${order.items.length - 2} sản phẩm khác...',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tổng tiền và nút hành động
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng tiền:',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                    _buildActionButton(order.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String status) {
    switch (status) {
      case 'pending':
        return OutlinedButton.icon(
          onPressed: () {
            // TODO: Implement cancel order functionality
            _showCancelOrderDialog();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: BorderSide(color: Colors.red.shade400),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.cancel_outlined, size: 16),
          label: const Text('Hủy đơn', style: TextStyle(fontSize: 12)),
        );
      case 'shipped':
        return ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement confirm delivery functionality
            _showConfirmDeliveryDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          icon: const Icon(Icons.check_circle_outline, size: 16),
          label: const Text('Đã nhận', style: TextStyle(fontSize: 12)),
        );
      case 'delivered':
        return OutlinedButton.icon(
          onPressed: () {
            // TODO: Implement rate order functionality
            _showRateOrderDialog();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
            side: BorderSide(color: Colors.orange.shade400),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.star_outline, size: 16),
          label: const Text('Đánh giá', style: TextStyle(fontSize: 12)),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showCancelOrderDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement cancel order logic
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Có, hủy đơn'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDeliveryDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận đã nhận hàng'),
        content: const Text('Bạn đã nhận được hàng và hài lòng với đơn hàng?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Chưa nhận'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement confirm delivery logic
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Đã nhận hàng'),
          ),
        ],
      ),
    );
  }

  void _showRateOrderDialog() {
    // TODO: Implement rate order dialog
    Get.snackbar(
      'Đánh giá đơn hàng',
      'Tính năng đang được phát triển',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String statusText;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        icon = Icons.access_time;
        statusText = 'Chờ xác nhận';
        break;
      case 'confirmed':
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        icon = Icons.verified_outlined;
        statusText = 'Đã xác nhận';
        break;
      case 'shipping':
        backgroundColor = Colors.purple.shade50;
        textColor = Colors.purple.shade800;
        icon = Icons.local_shipping;
        statusText = 'Đang vận chuyển';
        break;
      case 'shipped':
        backgroundColor = Colors.yellow.shade50;
        textColor = Colors.yellow.shade800;
        icon = Icons.delivery_dining;
        statusText = 'Đang giao hàng';
        break;
      case 'delivered':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        statusText = 'Đã giao';
        break;
      case 'cancelled':
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        icon = Icons.cancel;
        statusText = 'Đã hủy';
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade800;
        icon = Icons.help_outline;
        statusText = 'Không xác định';
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
            statusText,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(price);
  }
}