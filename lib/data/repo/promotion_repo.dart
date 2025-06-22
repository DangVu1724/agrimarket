import 'package:agrimarket/data/models/discount_code.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PromotionRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> addProductDiscount(ProductPromotionModel discount) async {
  await _db
      .collection('product_discounts')
      .doc(discount.id) 
      .set(discount.toJson());
}


  Future<List<ProductPromotionModel>> getProductDiscountsByStore(String storeId) async {
    final snapshot = await _db
        .collection('product_discounts')
        .where('storeId', isEqualTo: storeId)
        .get();

    return snapshot.docs.map((doc) =>
      ProductPromotionModel.fromJson({...doc.data(), 'id': doc.id})
    ).toList();
  }

  Future<void> deleteProductDiscount(String id) async {
    await _db.collection('product_discounts').doc(id).delete();
  }

  Future<void> addDiscountCode(DiscountCodeModel code) async {
    await _db
        .collection('discount_codes')
        .doc(code.id) 
        .set(code.toJson());
  }

  Future<List<DiscountCodeModel>> getDiscountCodesByStore(String storeId) async {
    final snapshot = await _db
        .collection('discount_codes')
        .where('storeId', isEqualTo: storeId)
        .get();

    return snapshot.docs.map((doc) =>
      DiscountCodeModel.fromJson({...doc.data(), 'id': doc.id})
    ).toList();
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

}
