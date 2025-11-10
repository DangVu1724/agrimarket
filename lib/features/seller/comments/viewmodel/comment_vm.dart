import 'dart:async';

import 'package:agrimarket/data/models/comment.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SellerCommentVm extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<Review> reviews = <Review>[].obs;
  final RxList<Review> filteredReviews = <Review>[].obs;

  // Phân trang
  final RxInt currentPage = 1.obs;
  final int reviewsPerPage = 5;
  final RxInt totalReviews = 0.obs;
  final RxBool hasMoreReviews = true.obs;

  // Lọc
  final RxInt selectedRating = 0.obs; 

  final RxString _currentStoreId = ''.obs;
  StreamSubscription<QuerySnapshot>? _reviewsSub;

  // Get reviews hiện tại cho trang hiện tại
  List<Review> get currentReviews {
    final startIndex = (currentPage.value - 1) * reviewsPerPage;
    final endIndex = startIndex + reviewsPerPage;
    return filteredReviews.length > endIndex 
        ? filteredReviews.sublist(startIndex, endIndex)
        : filteredReviews.sublist(startIndex);
  }

  // Kiểm tra xem còn trang tiếp theo không
  bool get hasNextPage => currentPage.value * reviewsPerPage < filteredReviews.length;
  bool get hasPreviousPage => currentPage.value > 1;



  Future<void> addComment(String storeId, String reviewId, Comment newComment) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('reviews')
          .where('reviewId', isEqualTo: reviewId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;

        await docRef.update({
          'comments': FieldValue.arrayUnion([newComment.toJson()]),
        });
        print('Đã thêm comment thành công vào reviewId: $reviewId');
      } else {
        print('Không tìm thấy review với reviewId: $reviewId');
      }
    } catch (e) {
      print('Lỗi khi thêm comment: $e');
      Get.snackbar('Lỗi', 'Không thể thêm phản hồi: $e');
    }
  }

  void listenReviews(String storeId) {
    _reviewsSub?.cancel();
    
    _currentStoreId.value = storeId;

    _reviewsSub = FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final list = snapshot.docs.map((doc) {
          final review = Review.fromJson(doc.data());
          review.comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return review;
        }).toList();

        reviews.value = list;
        applyRatingFilter(selectedRating.value);
        print('Realtime update: ${list.length} reviews loaded');
      },
      onError: (error) {
        print('Lỗi khi lắng nghe reviews: $error');
      },
    );
  }

  // Lọc reviews theo số sao (làm tròn xuống)
  void applyRatingFilter(int rating) {
    selectedRating.value = rating;
    
    if (rating == 0) {
      filteredReviews.value = List.from(reviews);
    } else {
      filteredReviews.value = reviews.where((review) {
        final roundedRating = review.rating.floor();
        return roundedRating == rating;
      }).toList();
    }
    
    // Reset về trang 1 khi lọc
    currentPage.value = 1;
    totalReviews.value = filteredReviews.length;
    hasMoreReviews.value = filteredReviews.length > reviewsPerPage;
  }

  // Phân trang
  void nextPage() {
    if (hasNextPage) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (hasPreviousPage) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    final totalPages = (filteredReviews.length / reviewsPerPage).ceil();
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  // Thống kê số lượng reviews theo sao (làm tròn xuống)
  Map<int, int> getRatingStats() {
    final stats = <int, int>{};
    
    for (int i = 1; i <= 5; i++) {
      stats[i] = 0;
    }
    
    for (final review in reviews) {
      final roundedRating = review.rating.floor();
      if (roundedRating >= 1 && roundedRating <= 5) {
        stats[roundedRating] = stats[roundedRating]! + 1;
      }
    }
    
    return stats;
  }

  int getRatingCount(int rating) {
    final stats = getRatingStats();
    return stats[rating] ?? 0;
  }

  Review? findReviewById(String reviewId) {
    try {
      return reviews.firstWhere((review) => review.reviewId == reviewId);
    } catch (e) {
      return null;
    }
  }

  @override
  void onClose() {
    _reviewsSub?.cancel();
    super.onClose();
  }
}
