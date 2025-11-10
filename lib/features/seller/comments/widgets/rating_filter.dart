import 'package:agrimarket/features/seller/comments/viewmodel/comment_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrimarket/app/theme/app_colors.dart';

class RatingFilterWidget extends StatelessWidget {
  const RatingFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<SellerCommentVm>();

    return Obx(() {
      final stats = vm.getRatingStats();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lọc theo mức đánh giá",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 4),
                FilterChip(
                  label: Text('Tất cả (${vm.reviews.length})'),
                  selected: vm.selectedRating.value == 0,
                  onSelected: (_) => vm.applyRatingFilter(0),
                  backgroundColor: Colors.grey[200],
                  selectedColor: AppColors.primary!.withOpacity(0.15),
                  checkmarkColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                for (int i = 5; i >= 1; i--) ...[
                  FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$i'),
                        const SizedBox(width: 2),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('(${stats[i] ?? 0})'),
                      ],
                    ),
                    selected: vm.selectedRating.value == i,
                    onSelected: (_) => vm.applyRatingFilter(i),
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.primary!.withOpacity(0.15),
                    checkmarkColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}
