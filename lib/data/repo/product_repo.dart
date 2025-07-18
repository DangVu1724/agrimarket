import 'package:agrimarket/data/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductRepository {
  final CollectionReference _productsCollection = FirebaseFirestore.instance.collection('products');

  Future<List<ProductModel>> fetchProductsByStoreId(String storeId) async {
    try {
      final querySnapshot = await _productsCollection
          .where('storeId', isEqualTo: storeId)
          .get();
      return querySnapshot.docs
          .map((doc) => ProductModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Không thể tải sản phẩm: $e');
    }
  }

  Future<DocumentReference> createProduct(ProductModel product) async {
    try {
      final productData = product.toJson();
      productData['createdAt'] = FieldValue.serverTimestamp();
      return await _productsCollection.add(productData);
    } catch (e) {
      throw Exception('Không thể tạo sản phẩm: $e');
    }
  }

  Future<void> updateProduct(String productId, ProductModel product) async {
    try {
      final productData = product.toJson()..remove('id');
      productData['updateAt'] = FieldValue.serverTimestamp();
      await _productsCollection.doc(productId).update(productData);
    } catch (e) {
      throw Exception('Không thể cập nhật sản phẩm: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      throw Exception('Không thể xóa sản phẩm: $e');
    }
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (doc.exists) {
        return ProductModel.fromJson(doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<ProductModel>> fetchProductListByStore(String storeID) async {
    try {
      final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeID).get();
      if (!storeDoc.exists || storeDoc.data()?['state'] != 'verify') {
      return [];
    }
      final querySnapshot =
          await FirebaseFirestore.instance.collection('products').where('storeId', isEqualTo: storeID).get();

      return querySnapshot.docs.map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id})).toList();
    } catch (e) {
      return [];
    }
  }
}