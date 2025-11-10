import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/seller/comments/viewmodel/comment_vm.dart';

class PaginationWidget extends StatelessWidget {
  const PaginationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<SellerCommentVm>();

    return Obx(() {
      if (vm.filteredReviews.isEmpty) return const SizedBox();

      final totalPages = (vm.filteredReviews.length / vm.reviewsPerPage).ceil();
      final currentPage = vm.currentPage.value;
      final totalReviews = vm.filteredReviews.length;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            // Thông tin tổng quan
            Text(
              'Hiển thị ${((currentPage - 1) * vm.reviewsPerPage) + 1}-${currentPage * vm.reviewsPerPage > totalReviews ? totalReviews : currentPage * vm.reviewsPerPage} / $totalReviews đánh giá',
              style: AppTextStyles.body.copyWith(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Nút điều hướng
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Trang đầu',
                  onPressed: currentPage > 1 ? () => vm.goToPage(1) : null,
                  icon: const Icon(Icons.first_page_rounded),
                  color: currentPage > 1 ? AppColors.primary : Colors.grey[400],
                ),
                IconButton(
                  tooltip: 'Trang trước',
                  onPressed: vm.hasPreviousPage ? () => vm.previousPage() : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: vm.hasPreviousPage ? AppColors.primary : Colors.grey[400],
                ),
                const SizedBox(width: 4),

                // Hiển thị các trang
                Wrap(
                  spacing: 4,
                  children: List.generate(totalPages, (index) {
                    final page = index + 1;
                    final isVisible = (page - currentPage).abs() <= 3 || page == 1 || page == totalPages;
                    if (!isVisible) return const SizedBox();
                    return GestureDetector(
                      onTap: () => vm.goToPage(page),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: page == currentPage ? AppColors.primary : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: page == currentPage ? AppColors.primary! : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$page',
                          style: TextStyle(
                            color: page == currentPage ? Colors.white : Colors.grey[800],
                            fontWeight: page == currentPage ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Trang kế tiếp',
                  onPressed: vm.hasNextPage ? () => vm.nextPage() : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: vm.hasNextPage ? AppColors.primary : Colors.grey[400],
                ),
                IconButton(
                  tooltip: 'Trang cuối',
                  onPressed: currentPage < totalPages ? () => vm.goToPage(totalPages) : null,
                  icon: const Icon(Icons.last_page_rounded),
                  color: currentPage < totalPages ? AppColors.primary : Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}