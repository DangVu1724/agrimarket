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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Chi tiết đơn hàng',
          style: AppTextStyles.headline.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            _buildStatusCard(),
            const SizedBox(height: 20),

            // Order Information
            _buildOrderInfoCard(),
            const SizedBox(height: 20),

            // Delivery Information
            _buildDeliveryCard(),
            const SizedBox(height: 20),

            // Products List
            _buildProductsCard(),
            const SizedBox(height: 20),

            // Payment Summary
            _buildPaymentCard(),
            const SizedBox(height: 20),

            // Review Section (if delivered)
            if (order.status == 'delivered') 
              _buildReviewCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trạng thái đơn hàng',
            style: AppTextStyles.headline.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          _buildModernStatusChip(order.status),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin đơn hàng',
            style: AppTextStyles.headline.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem('Mã đơn hàng', order.orderId, Icons.receipt_long),
          _buildInfoItem('Ngày đặt', _formatDate(order.createdAt), Icons.calendar_today),
          _buildInfoItem('Phương thức', order.paymentMethod, Icons.payment),
          _buildInfoItem('Cửa hàng', order.storeName?.isNotEmpty == true ? order.storeName! : order.storeId, Icons.store),
          _buildInfoItem('Người mua', order.buyerName ?? order.buyerUid, Icons.person),
          if (order.buyerPhone != null && order.buyerPhone!.isNotEmpty)
            _buildInfoItem('Điện thoại', order.buyerPhone!, Icons.phone),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin giao hàng',
            style: AppTextStyles.headline.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sản phẩm đã đặt',
            style: AppTextStyles.headline.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.map(_buildModernOrderItem).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng thanh toán',
            style: AppTextStyles.headline.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          if (order.discountPrice != null && order.discountPrice! > 0) ...[
            _buildPriceRow('Tổng tiền hàng', _formatPrice(order.totalPrice + order.discountPrice!)),
            _buildPriceRow('Giảm giá', '-${_formatPrice(order.discountPrice!)}', isDiscount: true),
            const Divider(height: 20),
          ],
          _buildPriceRow('Tổng thanh toán', _formatPrice(order.totalPrice), isTotal: true),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context) {
    final buyerOrderVm = Get.find<BuyerOrderVm>();
    buyerOrderVm.setOrderComment(order.comment, order.isReviewed ?? false);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đánh giá đơn hàng',
            style: AppTextStyles.headline.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),

          // Rating Stars
          Center(
            child: RatingBar.builder(
              itemSize: 32,
              initialRating: order.rating ?? 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                if (!buyerOrderVm.isReviewed.value) {
                  buyerOrderVm.rating.value = rating;
                }
              },
              ignoreGestures: buyerOrderVm.isReviewed.value,
            ),
          ),
          const SizedBox(height: 20),

          if (buyerOrderVm.isReviewed.value) ...[
            // Already Reviewed
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Bạn đã đánh giá đơn hàng này',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (buyerOrderVm.commentController.text.isNotEmpty)
                    Text(
                      buyerOrderVm.commentController.text,
                      style: const TextStyle(color: Colors.black87),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Review Images
            if (order.reviewImages != null && order.reviewImages!.isNotEmpty) ...[
              Text(
                'Hình ảnh đánh giá',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(order.reviewImages!.length, (index) {
                  final imageBase64 = order.reviewImages![index];
                  try {
                    final cleanBase64 = imageBase64.contains(',')
                        ? imageBase64.split(',').last
                        : imageBase64;
                    final sanitizedBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');
                    final bytes = base64Decode(sanitizedBase64);

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        bytes,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    );
                  } catch (e) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                    );
                  }
                }),
              ),
            ],
          ] else ...[
            // Not Reviewed - Review Form
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhận xét của bạn',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: buyerOrderVm.commentController,
                  maxLines: 4,
                  onChanged: (value) => buyerOrderVm.comment.value = value,
                  decoration: InputDecoration(
                    hintText: 'Chia sẻ trải nghiệm của bạn về đơn hàng...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Image Picker
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await buyerOrderVm.pickImages(context);
                      },
                      icon: const Icon(Icons.photo_library, size: 18),
                      label: const Text('Thêm hình ảnh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.grey.shade800,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (buyerOrderVm.images.isNotEmpty)
                      Text(
                        '${buyerOrderVm.images.length} ảnh đã chọn',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Selected Images
                if (buyerOrderVm.images.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      buyerOrderVm.images.length,
                      (index) => Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
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
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (buyerOrderVm.rating.value == 0) {
                        Get.snackbar(
                          'Thiếu thông tin',
                          'Vui lòng chọn số sao để đánh giá',
                          backgroundColor: Colors.orange,
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
                        buyerName: order.buyerName ?? '',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Gửi đánh giá',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      )),
    );
  }

  Widget _buildModernStatusChip(String status) {
    final statusConfig = _getStatusConfig(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusConfig.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusConfig.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusConfig.icon, color: statusConfig.iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusConfig.label,
            style: TextStyle(
              color: statusConfig.textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernOrderItem(OrderItem item) {
    final hasPromotion = item.promotionPrice != null && item.promotionPrice! > 0;
    final finalPrice = hasPromotion ? item.promotionPrice! : item.price;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} x ${_formatPrice(item.price)}/${item.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasPromotion) ...[
                Text(
                  _formatPrice(item.price * item.quantity),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                _formatPrice(finalPrice * item.quantity),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: hasPromotion ? AppColors.error : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.black87 : Colors.grey.shade700,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isDiscount ? Colors.red : (isTotal ? AppColors.primary : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'pending':
        return StatusConfig(
          label: 'Chờ xác nhận',
          icon: Icons.schedule,
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          iconColor: Colors.orange.shade600,
          textColor: Colors.orange.shade800,
        );
      case 'confirmed':
        return StatusConfig(
          label: 'Đã xác nhận',
          icon: Icons.check_circle_outline,
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          iconColor: Colors.blue.shade600,
          textColor: Colors.blue.shade800,
        );
      case 'shipping':
        return StatusConfig(
          label: 'Đang giao hàng',
          icon: Icons.local_shipping,
          backgroundColor: Colors.yellow.shade50,
          borderColor: Colors.yellow.shade200,
          iconColor: Colors.yellow.shade700,
          textColor: Colors.yellow.shade800,
        );
      case 'delivered':
        return StatusConfig(
          label: 'Đã giao hàng',
          icon: Icons.done_all,
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          iconColor: Colors.green.shade600,
          textColor: Colors.green.shade800,
        );
      case 'cancelled':
        return StatusConfig(
          label: 'Đã hủy',
          icon: Icons.cancel,
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
          iconColor: Colors.red.shade600,
          textColor: Colors.red.shade800,
        );
      default:
        return StatusConfig(
          label: status,
          icon: Icons.info_outline,
          backgroundColor: Colors.grey.shade100,
          borderColor: Colors.grey.shade300,
          iconColor: Colors.grey.shade600,
          textColor: Colors.grey.shade800,
        );
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('HH:mm - dd/MM/yyyy').format(date);
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(price);
  }
}

class StatusConfig {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  StatusConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}