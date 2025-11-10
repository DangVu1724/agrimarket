import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/data/models/comment.dart';
import 'package:agrimarket/features/buyer/store/widgets/comment_input_widget.dart';
import 'package:agrimarket/features/buyer/store/widgets/pagination_widget.dart';
import 'package:agrimarket/features/buyer/store/widgets/rating_filter_widget.dart';
import 'package:agrimarket/features/buyer/store/widgets/review_card_widget.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:agrimarket/features/seller/comments/viewmodel/comment_vm.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';


class SellerComment extends StatefulWidget {
  const SellerComment({super.key});

  @override
  State<SellerComment> createState() => _SellerCommentState();
}

class _SellerCommentState extends State<SellerComment> {
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, bool> _isExpanded = {};
  final Map<String, bool> _isSubmitting = {};

  @override
  void initState() {
    super.initState();
    final vm = Get.find<SellerCommentVm>();
    final SellerHomeVm homeVm = Get.find<SellerHomeVm>();
    final storeId = homeVm.store.value!.storeId;
    vm.listenReviews(storeId);
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

    final vm = Get.find<SellerCommentVm>();
    final SellerHomeVm homeVm = Get.find<SellerHomeVm>();
    final userVm = Get.find<UserVm>();

    final newComment = Comment(
      commentId: Uuid().v4(),
      content: content,
      createdAt: DateTime.now(),
      role: 'seller',
      userName: userVm.userName.value,
      userId: homeVm.store.value!.storeId,
    );

    try {
      await vm.addComment(homeVm.store.value!.storeId, reviewId, newComment);
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
    final vm = Get.find<SellerCommentVm>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Đánh giá & Góp ý"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentReviews = vm.currentReviews;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tổng quan rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 32),
                  const SizedBox(width: 8),
                  Obx(() {
                    final total = vm.reviews.length;
                    final avg = total > 0 ? vm.reviews.map((e) => e.rating).reduce((a, b) => a + b) / total : 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                        Text("Trung bình từ $total đánh giá", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Bộ lọc đánh giá
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                color: Colors.white,
                child: const Padding(padding: EdgeInsets.all(16), child: RatingFilterWidget()),
              ),
              const SizedBox(height: 20),

              // Danh sách review
              if (currentReviews.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.rate_review, color: Colors.grey, size: 64),
                      const SizedBox(height: 12),
                      Text("Chưa có đánh giá nào.", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                )
              else
                Column(
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
                    ),
                    const SizedBox(height: 8),
                    const PaginationWidget(),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }
}