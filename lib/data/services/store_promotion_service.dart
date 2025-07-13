import 'package:agrimarket/data/models/discount_code.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/repo/promotion_repo.dart';
import 'package:agrimarket/data/repo/store_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class StorePromotionService {
  final PromotionRepository _promotionRepo = PromotionRepository();
  final StoreRepository _storeRepo = StoreRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Kiểm tra và cập nhật trạng thái khuyến mãi cho một store
  Future<void> updateStorePromotionStatus(String storeId) async {
    try {
      // Kiểm tra xem store có khuyến mãi sản phẩm đang hoạt động không
      final productDiscounts = await _promotionRepo.getProductDiscountsByStore(storeId);
      final activeProductDiscounts =
          productDiscounts
              .where(
                (discount) =>
                    discount.isValid &&
                    DateTime.now().isAfter(discount.startDate) &&
                    DateTime.now().isBefore(discount.endDate),
              )
              .toList();

      // Kiểm tra xem store có mã giảm giá đang hoạt động không
      final discountCodes = await _promotionRepo.getDiscountCodesByStore(storeId);
      final activeDiscountCodes =
          discountCodes.where((code) => code.isOnSale && code.used < code.limit).toList();

      // Kiểm tra xem có sản phẩm nào đang có khuyến mãi không
      final productsWithPromotion = await _checkProductsWithPromotion(storeId);

      // Cập nhật trạng thái isPromotion
      final hasPromotion = activeProductDiscounts.isNotEmpty || activeDiscountCodes.isNotEmpty || productsWithPromotion;

      await _updateStorePromotionField(storeId, hasPromotion);

      print('🔄 Updated store $storeId promotion status: $hasPromotion');
    } catch (e) {
      print('❌ Error updating store promotion status: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái khuyến mãi: $e');
    }
  }

  /// Kiểm tra xem có sản phẩm nào đang có khuyến mãi không
  Future<bool> _checkProductsWithPromotion(String storeId) async {
    try {
      final snapshot =
          await _firestore
              .collection('products')
              .where('storeId', isEqualTo: storeId)
              .where('promotion', isNull: false)
              .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final promotionEndDate = data['promotionEndDate'];

        if (promotionEndDate != null) {
          final endDate =
              promotionEndDate is Timestamp
                  ? promotionEndDate.toDate()
                  : DateTime.tryParse(promotionEndDate.toString());

          if (endDate != null && DateTime.now().isBefore(endDate)) {
            return true; // Có sản phẩm đang khuyến mãi
          }
        }
      }
      return false;
    } catch (e) {
      print('❌ Error checking products with promotion: $e');
      return false;
    }
  }

  /// Cập nhật trường isPromotion trong database
  Future<void> _updateStorePromotionField(String storeId, bool isPromotion) async {
    try {
      await _firestore.collection('stores').doc(storeId).update({'isPromotion': isPromotion});
    } catch (e) {
      print('❌ Error updating store promotion field: $e');
      rethrow;
    }
  }

  /// Cập nhật trạng thái khuyến mãi cho tất cả stores
  Future<void> updateAllStoresPromotionStatus() async {
    try {
      final storesSnapshot = await _firestore.collection('stores').get();

      for (var doc in storesSnapshot.docs) {
        final storeId = doc.id;
        await updateStorePromotionStatus(storeId);
      }

      print('✅ Updated promotion status for all stores');
    } catch (e) {
      print('❌ Error updating all stores promotion status: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái khuyến mãi cho tất cả stores: $e');
    }
  }

  /// Lắng nghe thay đổi khuyến mãi và tự động cập nhật store
  void listenToPromotionChanges(String storeId) {
    // Lắng nghe thay đổi trong product_discounts
    _firestore.collection('product_discounts').where('storeId', isEqualTo: storeId).snapshots().listen((snapshot) {
      updateStorePromotionStatus(storeId);
    });

    // Lắng nghe thay đổi trong discount_codes
    _firestore.collection('discount_codes').where('storeId', isEqualTo: storeId).snapshots().listen((snapshot) {
      updateStorePromotionStatus(storeId);
    });

    // Lắng nghe thay đổi trong products
    _firestore.collection('products').where('storeId', isEqualTo: storeId).snapshots().listen((snapshot) {
      updateStorePromotionStatus(storeId);
    });
  }

  /// Dừng lắng nghe thay đổi
  void dispose() {
    // Có thể thêm logic để dừng các listeners nếu cần
  }
}
