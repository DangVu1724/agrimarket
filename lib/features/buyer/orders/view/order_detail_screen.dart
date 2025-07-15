import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/features/buyer/orders/v%E1%BB%89ewmodel/buyer_order_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chi tiết đơn hàng',
          style: AppTextStyles.headline.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Thông tin đơn hàng'),
            const SizedBox(height: 8),
            _infoRow('Mã đơn hàng', order.orderId),
            _infoRow('Ngày đặt', _formatDate(order.createdAt)),
            _infoRow('Phương thức thanh toán', order.paymentMethod),
            _infoRow('Cửa hàng', order.storeName?.isNotEmpty == true ? order.storeName! : order.storeId),
            const Divider(height: 32),

            _sectionTitle('Trạng thái đơn hàng'),
            const SizedBox(height: 8),
            _buildStatusChip(order.status),
            const Divider(height: 32),
            const SizedBox(height: 8),

            _sectionTitle('Thông tin giao hàng'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.grey),
                const SizedBox(width: 15),
                Expanded(child: Text(order.deliveryAddress, style: AppTextStyles.body)),
              ],
            ),
            const Divider(height: 32),

            _sectionTitle('Sản phẩm đã đặt'),
            const SizedBox(height: 12),
            ...order.items.map(_buildOrderItem).toList(),
            const Divider(height: 32),

            _sectionTitle('Tổng cộng'),
            const SizedBox(height: 8),
            if (order.discountPrice != null && order.discountPrice! > 0) ...[
              _priceRow('Tổng tiền hàng', _formatPrice(order.totalPrice + order.discountPrice!)),
              _priceRow('Giảm giá', '-${_formatPrice(order.discountPrice!)}', isDiscount: true),
            ],
            _priceRow('Tổng thanh toán', _formatPrice(order.totalPrice), isTotal: true),
            const Divider(height: 32),
            if (order.status == 'delivered') ...[
              _sectionTitle('Đánh giá'),
              const SizedBox(height: 8),
              _buildReviewSection(context, order),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headline.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text('$label:', style: AppTextStyles.body.copyWith(color: Colors.grey[600]))),
          Expanded(child: Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} x ${_formatPrice(item.price)}/${item.unit}',
                  style: AppTextStyles.body.copyWith(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              _formatPrice(item.price * item.quantity),
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body.copyWith(color: Colors.grey[700])),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: isDiscount ? Colors.red : (isTotal ? AppColors.primary : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.schedule;
        break;
      case 'confirmed':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        icon = Icons.check_circle_outline;
        break;
      case 'shipping':
        backgroundColor = Colors.yellow[100]!;
        textColor = Colors.yellow[800]!;
        icon = Icons.local_shipping;
        break;
      case 'shipped':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.done_all;
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[800]!;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 6),
          Text(status, style: AppTextStyles.body.copyWith(color: textColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context, OrderModel order) {
    final buyerOrderVm = Get.find<BuyerOrderVm>();
    buyerOrderVm.setOrderComment(order.comment, order.isReviewed ?? false);

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RatingBar.builder(
            itemSize: 26,
            initialRating: order.rating ?? 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              if (!buyerOrderVm.isReviewed.value) {
                buyerOrderVm.rating.value = rating;
              }
            },
            ignoreGestures: buyerOrderVm.isReviewed.value,
          ),
          const SizedBox(height: 8),
          if (buyerOrderVm.isReviewed.value) ...[
            Text(
              'Bạn đã đánh giá đơn hàng này.',
              style: AppTextStyles.body.copyWith(color: Colors.green[700], fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              buyerOrderVm.commentController.text.isEmpty ? 'Không có bình luận' : buyerOrderVm.commentController.text,
              style: AppTextStyles.body.copyWith(color: Colors.black87),
            ),
          ] else ...[
            TextFormField(
              controller: buyerOrderVm.commentController,
              maxLines: 3,
              enabled: !buyerOrderVm.isReviewed.value,
              onChanged: (value) {
                buyerOrderVm.comment.value = value;
              },
              decoration: InputDecoration(
                hintText: 'Nhập đánh giá',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed:
                  buyerOrderVm.isReviewed.value
                      ? null
                      : () {
                        if (buyerOrderVm.rating.value == 0) {
                          Get.snackbar(
                            'Lỗi',
                            'Vui lòng chọn số sao để đánh giá',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        buyerOrderVm.submitReview(
                          orderId: order.orderId,
                          rating: buyerOrderVm.rating.value,
                          comment: buyerOrderVm.comment.value,
                          storeId: order.storeId,
                          buyerUid: order.buyerUid,
                        );
                      },
              child: const Text('Gửi đánh giá'),
            ),
          ],
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
