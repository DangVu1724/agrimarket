import 'package:agrimarket/data/models/discount_code.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionRepository {
  final _db = FirebaseFirestore.instance;

  Future<ProductPromotionModel> addProductDiscount(ProductPromotionModel discount) async {
    try {
      final docRef = _db.collection('product_discounts').doc();

      // Tạo bản sao của discount với ID mới
      final discountWithId = discount.copyWith(id: docRef.id);

      await docRef.set(discountWithId.toJson());

      return discountWithId; // Trả về discount đã có ID
    } catch (e) {
      throw Exception('Failed to add discount: ${e.toString()}');
    }
  }

  Future<List<ProductPromotionModel>> getProductDiscountsByStore(String storeId) async {
    final snapshot = await _db.collection('product_discounts').where('storeId', isEqualTo: storeId).get();

    return snapshot.docs.map((doc) => ProductPromotionModel.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  Future<void> deleteProductDiscount(String id) async {
    await _db.collection('product_discounts').doc(id).delete();
  }

  Future<DiscountCodeModel> addDiscountCode(DiscountCodeModel code) async {
    try {
      final docRef = _db.collection('discount_codes').doc();

      final codeId = code.copyWith(id: docRef.id);

      await docRef.set(codeId.toJson());

      return codeId;
    } catch (e) {
      throw Exception('Failed to add discount: ${e.toString()}');
    }
  }

  Future<List<DiscountCodeModel>> getDiscountCodesByStore(String storeId) async {
    final snapshot = await _db.collection('discount_codes').where('storeId', isEqualTo: storeId).get();

    return snapshot.docs.map((doc) => DiscountCodeModel.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  Future<void> deleteDiscountCode(String id) async {
    await _db.collection('discount_codes').doc(id).delete();
  }

  Future<void> updateDiscountCode(DiscountCodeModel code) async {
    await _db.collection('discount_codes').doc(code.id).update(code.toJson());
  }

  Future<void> updateProductDiscount(ProductPromotionModel discount) async {
    await _db.collection('product_discounts').doc(discount.id).update(discount.toJson());
  }

  Future<ProductPromotionModel?> getDiscountInfo(String discountId) async {
    try {
      final doc = await _db.collection('product_discounts').doc(discountId).get();

      if (!doc.exists) return null;

      return ProductPromotionModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  Future<List<DiscountCodeModel>> getAllDiscountCodes(String storeId) async {
    final doc1 = await _db.collection('discount_codes').where('storeId', isEqualTo: storeId).get();
    final doc2 = await _db.collection('discount_codes').where('storeId', isNull: true).get();
    final allDoc = [...doc1.docs, ...doc2.docs];
    return allDoc.map((e) => DiscountCodeModel.fromJson({...e.data(), 'id': e.id})).where((e) => e.isOnSale).toList();
  }


}
