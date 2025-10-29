import 'dart:convert';

import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/features/buyer/store/viewmodel/store_detail_vm.dart';
import 'package:flutter/material.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

class StoreDetailScreen extends StatelessWidget {
  final StoreModel store;
  const StoreDetailScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<StoreDetailVm>();
    return Scaffold(
      appBar: AppBar(
        title: Text(store.name, style: AppTextStyles.headline),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh cửa hàng
            if (store.storeImageUrl != null && store.storeImageUrl!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  store.storeImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store, color: AppColors.primary, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          store.name,
                          style: AppTextStyles.headline.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          store.storeLocation.address,
                          style: AppTextStyles.body.copyWith(fontSize: 15, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blue, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        store.isOpened ? 'Mở cửa' : 'Đóng cửa',
                        style: TextStyle(
                          color: store.isOpened ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Mô tả cửa hàng:', style: AppTextStyles.headline.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    store.description.isNotEmpty ? store.description : 'Chưa có mô tả.',
                    style: AppTextStyles.body.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  Text('Danh mục:', style: AppTextStyles.headline.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children:
                        store.categories
                            .map((cat) => Chip(backgroundColor: AppColors.background, label: Text(cat)))
                            .toList(),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Text('Đánh giá', style: AppTextStyles.headline.copyWith(fontSize: 16)),
                      const SizedBox(width: 4),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      if (store.rating != null) ...{
                        Text(store.rating.toString(), style: AppTextStyles.body.copyWith(fontSize: 15)),
                      } else ...{
                        Text('Chưa có đánh giá', style: AppTextStyles.body.copyWith(fontSize: 15, color: Colors.grey)),
                      },
                      const SizedBox(width: 4),
                      if (store.totalReviews != null) ...{
                        Text(
                          '(${store.totalReviews})',
                          style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.grey),
                        ),
                      } else ...{
                        Text('(0)', style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.grey)),
                      },
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vm.reviews.length,
                    itemBuilder: (context, index) {
                      final review = vm.reviews[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.green[200],
                              child: Icon(Icons.person, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            // Nội dung review
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tên hoặc UID (ẩn bớt)
                                  Text(
                                    'Người dùng: ${review.buyerUid.substring(0, 6)}***',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  // Số sao
                                  RatingBarIndicator(
                                    rating: review.rating,
                                    itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                                    itemCount: 5,
                                    itemSize: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  // Ngày đánh giá
                                  Text(
                                    'Ngày: ${DateFormat('dd/MM/yyyy').format(review.createdAt)}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  // Nội dung comment
                                  Text(review.comment, style: TextStyle(fontSize: 15)),
                                  if (review.reviewImages != null && review.reviewImages!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 80,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: review.reviewImages!.length,
                                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                                        itemBuilder: (context, imgIndex) {
                                          final imgData = review.reviewImages![imgIndex];
                                          final bytes = base64Decode(imgData);
                                          return GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (_) => Dialog(
                                                      backgroundColor: Colors.black,
                                                      insetPadding: EdgeInsets.zero,
                                                      child: Stack(
                                                        children: [
                                                          PhotoView(
                                                            imageProvider: MemoryImage(bytes),
                                                            backgroundDecoration: const BoxDecoration(
                                                              color: Colors.black,
                                                            ),
                                                            minScale: PhotoViewComputedScale.contained,
                                                            maxScale: PhotoViewComputedScale.covered * 2,
                                                          ),
                                                          Positioned(
                                                            top: 40,
                                                            right: 20,
                                                            child: IconButton(
                                                              icon: const Icon(
                                                                Icons.close,
                                                                color: Colors.white,
                                                                size: 28,
                                                              ),
                                                              onPressed: () => Navigator.pop(context),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.memory(bytes, width: 80, height: 80, fit: BoxFit.cover),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
