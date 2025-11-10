import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/buyer/store/viewmodel/store_detail_vm.dart';

class RatingFilterWidget extends StatelessWidget {
  const RatingFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<StoreDetailVm>();

    return Obx(() {
      final ratingStats = vm.getRatingStats();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lọc theo mức đánh giá",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[800]),
          ),
          const SizedBox(height: 12),

          // Hàng chip cuộn ngang
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
                  labelStyle: TextStyle(
                    color: vm.selectedRating.value == 0 ? AppColors.primary : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
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
                        Text('(${ratingStats[i] ?? 0})'),
                      ],
                    ),
                    selected: vm.selectedRating.value == i,
                    onSelected: (_) => vm.applyRatingFilter(i),
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.primary!.withOpacity(0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: vm.selectedRating.value == i ? AppColors.primary : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
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