import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/features/buyer/store/widgets/comment_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';

import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/seller/comments/viewmodel/comment_vm.dart';

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
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Người dùng: ${review.buyerUid.substring(0, 6)}***",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: review.rating,
                            itemBuilder: (_, _) => const Icon(Icons.star, color: Colors.amber),
                            itemSize: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd/MM/yyyy').format(review.createdAt),
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(review.comment, style: const TextStyle(fontSize: 15, height: 1.4)),

            // Ảnh review
            if (review.reviewImages?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.reviewImages!.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final img = base64Decode(review.reviewImages![i]);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(img, width: 80, height: 80, fit: BoxFit.cover),
                    );
                  },
                ),
              ),
            ],

            // Comment list
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

            const SizedBox(height: 14),
            commentInput,
          ],
        ),
      ),
    );
  }
}