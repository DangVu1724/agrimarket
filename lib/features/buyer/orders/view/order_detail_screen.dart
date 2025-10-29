import 'dart:convert';

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
            _infoRow('Người mua', order.buyerName ?? order.buyerUid),
            _infoRow('Số điện thoại', order.buyerPhone ?? ''),

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            flex: 2,
            child: Column(
              children: [
                if (item.promotionPrice != null && item.promotionPrice! > 0) ...[
                  Text(
                    _formatPrice(item.price * item.quantity),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      fontSize: 13,
                      decoration: TextDecoration.lineThrough,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    _formatPrice((item.promotionPrice ?? 0) * item.quantity),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ] else ...[
                  Text(
                    _formatPrice(item.price * item.quantity),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ],
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
  print('🧩 order.reviewImages = ${order.reviewImages}');

  return Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⭐ Đánh giá sao
          RatingBar.builder(
            itemSize: 26,
            initialRating: order.rating ?? 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              if (!buyerOrderVm.isReviewed.value) {
                buyerOrderVm.rating.value = rating;
              }
            },
            ignoreGestures: buyerOrderVm.isReviewed.value,
          ),
          const SizedBox(height: 8),

          // 📄 Nếu đã đánh giá
          if (buyerOrderVm.isReviewed.value) ...[
            Text(
              'Bạn đã đánh giá đơn hàng này.',
              style: AppTextStyles.body.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // 🔹 Hiện bình luận cũ
            Text(
              buyerOrderVm.commentController.text.isEmpty
                  ? 'Không có bình luận'
                  : buyerOrderVm.commentController.text,
              style: AppTextStyles.body.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 8),

            // 🖼️ Hiện ảnh đánh giá cũ (nếu có)
            if (order.reviewImages != null && order.reviewImages!.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(order.reviewImages!.length, (index) {
                  final imageBase64 = order.reviewImages![index];
                  try {
                    final cleanBase64 = imageBase64.contains(',')
                        ? imageBase64.split(',').last
                        : imageBase64;
                    final sanitizedBase64 =
                        cleanBase64.replaceAll(RegExp(r'\s+'), '');
                    final bytes = base64Decode(sanitizedBase64);

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        bytes,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    );
                  } catch (e) {
                    print('⚠️ Lỗi decode ảnh: $e');
                    return const Icon(Icons.broken_image,
                        size: 80, color: Colors.grey);
                  }
                }),
              ),
          ] else ...[
            // 📝 Chưa đánh giá → nhập đánh giá mới
            TextFormField(
              controller: buyerOrderVm.commentController,
              maxLines: 3,
              onChanged: (value) => buyerOrderVm.comment.value = value,
              decoration: InputDecoration(
                hintText: 'Nhập đánh giá của bạn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 📸 Chọn ảnh mới
            ElevatedButton.icon(
              onPressed: () async {
                await buyerOrderVm.pickImages(context);
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Thêm hình ảnh'),
            ),
            const SizedBox(height: 8),

            // 🖼️ Hiển thị ảnh mới chọn
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                buyerOrderVm.images.length,
                (index) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        buyerOrderVm.images[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => buyerOrderVm.removeImage(index),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🔘 Nút gửi đánh giá
            ElevatedButton(
              onPressed: () {
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
      ));
}


  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(price);
  }
}
