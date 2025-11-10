import 'package:agrimarket/data/models/store.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';

import 'package:photo_view/photo_view.dart';

import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import '../widgets/comment_item_widget.dart';

class ReviewCardWidget extends StatelessWidget {
  final Review review;
  final Widget commentInput;

  const ReviewCardWidget({
    super.key,
    required this.review,
    required this.commentInput,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với thông tin người đánh giá
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(Icons.person, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.buyerName,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: review.rating,
                          itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 16,
                        ),
                        const SizedBox(width: 8),
                        // Hiển thị rating gốc
                        Text(
                          '${review.rating}',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy').format(review.createdAt),
                          style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Nội dung review
          Text(review.comment, style: AppTextStyles.body.copyWith(fontSize: 15)),

          // Ảnh review (nếu có)
          if (review.reviewImages != null && review.reviewImages!.isNotEmpty) ...[
            const SizedBox(height: 12),
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
                        builder: (_) => Dialog(
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

          // Danh sách comments
          if (review.comments.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Phản hồi:',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            ...review.comments.map((comment) => CommentItemWidget(comment: comment)).toList(),
          ],

          // Ô nhập phản hồi mới
          const SizedBox(height: 12),
          commentInput,
        ],
      ),
    );
  }
}