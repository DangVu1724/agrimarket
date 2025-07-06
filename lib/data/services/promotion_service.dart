import 'package:agrimarket/data/models/discount_code.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/data/repo/promotion_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'dart:async';

class PromotionService {
  final PromotionRepository _repo = PromotionRepository();
  final Box _promotionBox = Hive.box('promotionCache');

  static const _cacheDuration = 10 * 60 * 1000; // 10 phút

  // Cache cho promotions
  final RxMap<String, ProductPromotionModel> _promotionsCache = <String, ProductPromotionModel>{}.obs;
  Timer? _promotionTimer;

  Future<void> createProductDiscount(ProductPromotionModel discount) async {
    // Validate, log, etc...
    await _repo.addProductDiscount(discount);
  }

  Future<void> createDiscountCode(DiscountCodeModel code) async {
    // Validate, prevent duplicate code, etc...
    await _repo.addDiscountCode(code);
  }

  Future<List<ProductPromotionModel>> getProductDiscounts(String storeId) {
    return _repo.getProductDiscountsByStore(storeId);
  }

  Future<List<DiscountCodeModel>> getDiscountCodes(String storeId) {
    return _repo.getDiscountCodesByStore(storeId);
  }

  Future<void> removeProductDiscount(String id) {
    return _repo.deleteProductDiscount(id);
  }

  Future<void> removeDiscountCode(String id) {
    return _repo.deleteDiscountCode(id);
  }

  Future<void> updateDiscountCode(DiscountCodeModel code) {
    return _repo.updateDiscountCode(code);
  }

  Future<void> updateProductDiscount(ProductPromotionModel discount) {
    return _repo.updateProductDiscount(discount);
  }

  Future<void> addProductToDiscount(String discountId, String productId) async {
    final docRef = FirebaseFirestore.instance.collection('product_discounts').doc(discountId);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data()!;
      final currentProductIds = List<String>.from(data['productIds'] ?? []);

      if (!currentProductIds.contains(productId)) {
        currentProductIds.add(productId);
        await docRef.update({'productIds': currentProductIds});
      }
    }
  }

  Future<void> removeProductFromDiscount(String discountId, String productId) async {
    final docRef = FirebaseFirestore.instance.collection('product_discounts').doc(discountId);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data()!;

      final currentProductIds = List<String>.from(data['productIds'] ?? []);

      if (currentProductIds.contains(productId)) {
        currentProductIds.remove(productId);
        await docRef.update({'productIds': currentProductIds});
      } else {}
    } else {
      throw Exception('Discount not found');
    }
  }

  Future<ProductPromotionModel?> getDiscountInfo(String promotionId) async {
    // Kiểm tra cache trước
    if (_promotionsCache.containsKey(promotionId)) {
      return _promotionsCache[promotionId];
    }

    final cachedPromotion = _promotionBox.get('promotion_$promotionId');
    final cacheTimestamp = _promotionBox.get('promotion_${promotionId}_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cachedPromotion != null && cacheTimestamp != null && now - cacheTimestamp < _cacheDuration) {
      try {
        final promotion = ProductPromotionModel.fromJson(Map<String, dynamic>.from(cachedPromotion));
        _promotionsCache[promotionId] = promotion;
        return promotion;
      } catch (e) {
        _promotionBox.delete('promotion_$promotionId');
        _promotionBox.delete('promotion_${promotionId}_timestamp');
      }
    }

    // Lấy từ repository nếu không có cache hoặc cache hết hạn
    try {
      final promotion = await _repo.getDiscountInfo(promotionId);
      if (promotion != null) {
        // Lưu vào cache
        _promotionsCache[promotionId] = promotion;
        _promotionBox.put('promotion_$promotionId', promotion.toJson());
        _promotionBox.put('promotion_${promotionId}_timestamp', now);
      }
      return promotion;
    } catch (e) {
      print('Error loading promotion $promotionId: $e');
      return null;
    }
  }

  // Load multiple promotions
  Future<void> loadMultiplePromotions(List<String> promotionIds) async {
    if (promotionIds.isEmpty) return;
    final idsToLoad = promotionIds.where((id) => !_promotionsCache.containsKey(id)).toList();
    if (idsToLoad.isEmpty) return;

    try {
      final promotions = await Future.wait(idsToLoad.map((id) => getDiscountInfo(id)));
      for (int i = 0; i < idsToLoad.length; i++) {
        if (promotions[i] != null) {
          _promotionsCache[idsToLoad[i]] = promotions[i]!;
        }
      }
    } catch (e) {
      print('Error loading multiple promotions: $e');
    }
  }

  // Lấy promotion từ cache (sync)
  ProductPromotionModel? getDiscountInfoSync(String discountId) {
    return _promotionsCache[discountId];
  }

  // Xóa cache cho một promotion cụ thể
  void clearPromotionCache(String promotionId) {
    _promotionBox.delete('promotion_$promotionId');
    _promotionBox.delete('promotion_${promotionId}_timestamp');
    _promotionsCache.remove(promotionId);
  }

  // Xóa tất cả cache promotion
  void clearAllPromotionCache() {
    _promotionBox.clear();
    _promotionsCache.clear();
  }

  // Bắt đầu timer kiểm tra promotion hết hạn
  void startPromotionCheckTimer() {
    _promotionTimer?.cancel();
    _promotionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // Logic kiểm tra promotion hết hạn có thể được thêm ở đây
      // hoặc được gọi từ ViewModel
    });
  }

  // Dừng timer
  void stopPromotionCheckTimer() {
    _promotionTimer?.cancel();
  }

  // Dispose
  void dispose() {
    _promotionTimer?.cancel();
  }

  Future<DiscountCodeModel?> getDiscountCodeInfo(String codeId) async {
    final doc = await FirebaseFirestore.instance.collection('discount_codes').doc(codeId).get();

    if (!doc.exists) return null;

    return DiscountCodeModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<List<DiscountCodeModel>> getAllDiscountCodes(String storeId) async {
    return _repo.getAllDiscountCodes(storeId);
  }
}
