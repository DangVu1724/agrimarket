import 'package:agrimarket/data/models/discount_code.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/data/repo/promotion_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionService {
  final PromotionRepository _repo = PromotionRepository();

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
    final docRef = FirebaseFirestore.instance
        .collection('product_discounts')
        .doc(discountId);
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

  Future<void> removeProductFromDiscount(
    String discountId,
    String productId,
  ) async {
    final docRef = FirebaseFirestore.instance
        .collection('product_discounts')
        .doc(discountId);
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

  Future<Map<String, dynamic>?> getDiscountInfo(String discountId) async {
  final doc = await FirebaseFirestore.instance
      .collection('product_discounts')
      .doc(discountId)
      .get();

  if (!doc.exists) return null;

  final data = doc.data()!;
  return {
    'discountType': data['discountType'],
    'discountValue': data['discountValue'],
  };
}
  Future<Map<String, dynamic>?> getDiscountCodeInfo(String codeId) async {
    final doc = await FirebaseFirestore.instance
        .collection('discount_codes')
        .doc(codeId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    return {
      'code': data['code'],
      'discountValue': data['discountValue'],
      'expiryDate': data['expiryDate'],
    };
  }

}
