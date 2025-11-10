import 'package:agrimarket/data/models/comment.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/buyer/store/viewmodel/store_detail_vm.dart';
import 'package:uuid/uuid.dart';

import '../widgets/store_info_widget.dart';
import '../widgets/comment_input_widget.dart';
import '../widgets/comment_item_widget.dart';
import '../widgets/rating_filter_widget.dart';
import '../widgets/pagination_widget.dart';
import '../widgets/review_card_widget.dart';

class StoreDetailScreen extends StatefulWidget {
  final StoreModel store;
  const StoreDetailScreen({super.key, required this.store});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, bool> _isExpanded = {};
  final Map<String, bool> _isSubmitting = {};

  @override
  void initState() {
    super.initState();

    final vm = Get.find<StoreDetailVm>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.loadStoreData(widget.store.storeId);
    });
  }

  @override
  void dispose() {
    _commentControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  TextEditingController _getCommentController(String reviewId) {
    if (!_commentControllers.containsKey(reviewId)) {
      _commentControllers[reviewId] = TextEditingController();
      _isSubmitting[reviewId] = false;
    }
    return _commentControllers[reviewId]!;
  }

  bool _getIsSubmitting(String reviewId) {
    return _isSubmitting[reviewId] ?? false;
  }

  void _setIsSubmitting(String reviewId, bool value) {
    setState(() {
      _isSubmitting[reviewId] = value;
    });
  }

  Future<void> _submitComment(String reviewId) async {
    final controller = _getCommentController(reviewId);
    final content = controller.text.trim();

    if (content.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập nội dung phản hồi', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    _setIsSubmitting(reviewId, true);

    final vm = Get.find<StoreDetailVm>();
    final userVm = Get.find<UserVm>();

    final newComment = Comment(
      commentId: Uuid().v4(),
      content: content,
      createdAt: DateTime.now(),
      role: userVm.userRole.value,
      userName: userVm.userName.value,
      userId: userVm.userId.value,
    );

    try {
      await vm.addComment(widget.store.storeId, reviewId, newComment);
      controller.clear();
      setState(() {
        _isExpanded[reviewId] = false;
      });
      Get.snackbar('Thành công', 'Đã thêm phản hồi', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm phản hồi: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      _setIsSubmitting(reviewId, false);
    }
  }

  void _toggleCommentInput(String reviewId) {
    setState(() {
      _isExpanded[reviewId] = !(_isExpanded[reviewId] ?? false);
      if (!_isExpanded[reviewId]!) {
        _getCommentController(reviewId).clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<StoreDetailVm>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.store.name, style: AppTextStyles.headline),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh cửa hàng
            if (widget.store.storeImageUrl != null && widget.store.storeImageUrl!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  widget.store.storeImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin cửa hàng
                  StoreInfoWidget(store: widget.store),
                  const SizedBox(height: 24),

                  // Phần đánh giá với lọc và phân trang
                  _buildReviewSection(vm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(StoreDetailVm vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Đánh giá', style: AppTextStyles.headline.copyWith(fontSize: 18)),
            const SizedBox(width: 8),
            Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Obx(() {
              final totalReviews = vm.reviews.length;
              final avgRating = totalReviews > 0
                  ? vm.reviews.map((e) => e.rating).reduce((a, b) => a + b) / totalReviews
                  : 0;

              return Text(
                '${avgRating.toStringAsFixed(1)} ($totalReviews)',
                style: AppTextStyles.body.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              );
            }),
          ],
        ),
        const SizedBox(height: 16),

        // Bộ lọc đánh giá
        const RatingFilterWidget(),
        const SizedBox(height: 20),

        // Phân trang
        const PaginationWidget(),
        const SizedBox(height: 16),

        // Danh sách reviews
        Obx(() {
          if (vm.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentReviews = vm.currentReviews;

          if (currentReviews.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.reviews, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    vm.selectedRating.value == 0
                        ? 'Chưa có đánh giá nào'
                        : 'Không có đánh giá ${vm.selectedRating.value} sao',
                    style: AppTextStyles.body.copyWith(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              ...currentReviews.map(
                    (review) => ReviewCardWidget(
                  review: review,
                  commentInput: CommentInputWidget(
                    reviewId: review.reviewId,
                    getCommentController: _getCommentController,
                    getIsSubmitting: _getIsSubmitting,
                    isExpanded: _isExpanded[review.reviewId] ?? false,
                    toggleCommentInput: _toggleCommentInput,
                    submitComment: _submitComment,
                  ),
                ),
              ).toList(),

              // Phân trang ở dưới cùng
              const SizedBox(height: 20),
              const PaginationWidget(),
            ],
          );
        }),
      ],
    );
  }
}