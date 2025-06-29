import 'package:agrimarket/data/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProductFilterService {
  List<ProductModel> filterProducts(
    List<ProductModel> products,
    String storeId,
    String selectedCategory,
    String searchQuery,
  ) {
    var filtered = products.where((product) => product.storeId == storeId).toList();

    if (selectedCategory.isNotEmpty) {
      filtered = filtered.where((product) => product.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((product) => product.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  Future<List<ProductModel>> fetchProductListByStore(String storeID) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('products').where('storeId', isEqualTo: storeID).get();

      return querySnapshot.docs.map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id})).toList();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách cửa hàng: $e');
      return [];
    }
  }
}
