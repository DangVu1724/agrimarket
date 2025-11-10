import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/data/models/comment.dart';

class CommentItemWidget extends StatelessWidget {
  final Comment comment;

  const CommentItemWidget({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final bool isSeller = comment.role.toLowerCase() == 'seller';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSeller) // Buyer avatar bên trái
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.green[500]!,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 12,
              ),
            ),

          if (!isSeller) const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: isSeller ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Tên và thời gian
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: isSeller ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (isSeller)
                        Text(
                          DateFormat('HH:mm • dd/MM').format(comment.createdAt),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      if (isSeller) const SizedBox(width: 8),
                      Text(
                        comment.userName,
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSeller ? AppColors.primary : Colors.green[600],
                        ),
                      ),
                      if (!isSeller) const SizedBox(width: 8),
                      if (!isSeller)
                        Text(
                          DateFormat('HH:mm • dd/MM').format(comment.createdAt),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Bubble chat
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSeller
                        ? AppColors.primary!.withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: isSeller ? const Radius.circular(12) : const Radius.circular(4),
                      topRight: isSeller ? const Radius.circular(4) : const Radius.circular(12),
                      bottomLeft: const Radius.circular(12),
                      bottomRight: const Radius.circular(12),
                    ),
                    border: Border.all(
                      color: isSeller
                          ? AppColors.primary!.withOpacity(0.2)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    comment.content,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isSeller) const SizedBox(width: 8),

          if (isSeller) // Seller avatar bên phải
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.store,
                color: Colors.white,
                size: 12,
              ),
            ),
        ],
      ),
    );
  }
}