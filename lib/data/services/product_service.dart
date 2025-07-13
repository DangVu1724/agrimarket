import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/repo/product_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'dart:async';

class ProductService {
  final ProductRepository _productRepository = ProductRepository();
  final Box _productBox = Hive.box('productCache');

  static const _cacheDuration = 10 * 60 * 1000; // 10 phút

  // Cache cho products theo store
  final RxMap<String, List<ProductModel>> _productsCache = <String, List<ProductModel>>{}.obs;
  StreamSubscription? _productsSubscription;

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
    // Kiểm tra cache trước
    final key = 'products_store_$storeID';
    final timestampKey = '${key}_timestamp';
    final cached = _productBox.get(key);
    final timestamp = _productBox.get(timestampKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cached != null && timestamp != null && now - timestamp < _cacheDuration) {
      try {
        final products = (cached as List).cast<ProductModel>();
        _productsCache[storeID] = products;
        return products;
      } catch (e) {
        _productBox.delete(key);
        _productBox.delete(timestampKey);
      }
    }

    // Lấy từ repository nếu không có cache hoặc cache hết hạn
    final products = await _productRepository.fetchProductListByStore(storeID);

    // Lưu vào cache
    _productBox.put(key, products);
    _productBox.put(timestampKey, now);
    _productsCache[storeID] = products;

    return products;
  }

  // Realtime listener cho products
  void listenToProducts(String storeId) {
    _productsSubscription?.cancel();
    _productsSubscription = FirebaseFirestore.instance
        .collection('products')
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .listen(
          (snapshot) {
            final products = snapshot.docs.map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id})).toList();

            _productsCache[storeId] = products;

            // Cập nhật cache
            final key = 'products_store_$storeId';
            final timestampKey = '${key}_timestamp';
            _productBox.put(key, products);
            _productBox.put(timestampKey, DateTime.now().millisecondsSinceEpoch);

            print('Stream updated ${snapshot.docs.length} products for store $storeId');
          },
          onError: (e) {
            print('Stream error: $e');
            Get.snackbar('Lỗi', 'Không thể đồng bộ sản phẩm: $e');
          },
        );
  }

  // Lấy products từ cache (reactive)
  List<ProductModel>? getProductsForStore(String storeId) {
    return _productsCache[storeId];
  }

  // Xóa cache cho một store cụ thể
  void clearProductCacheForStore(String storeID) {
    final key = 'products_store_$storeID';
    final timestampKey = '${key}_timestamp';
    _productBox.delete(key);
    _productBox.delete(timestampKey);
    _productsCache.remove(storeID);
  }

  // Xóa tất cả cache sản phẩm
  void clearAllProductCache() {
    _productBox.clear();
    _productsCache.clear();
  }

  // Lấy sản phẩm từ cache (không gọi API)
  List<ProductModel>? getProductsFromCache(String storeID) {
    final key = 'products_store_$storeID';
    final cached = _productBox.get(key);
    if (cached != null) {
      try {
        return (cached as List).cast<ProductModel>();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Filter products theo IDs
  List<ProductModel> filterProductsByIds(List<String> ids, String storeId) {
    final currentProducts = _productsCache[storeId] ?? [];
    return currentProducts.where((p) => ids.contains(p.id)).toList();
  }

  // Hủy subscription
  void dispose() {
    _productsSubscription?.cancel();
  }

  // Stop listening to current store
  void stopListening() {
    _productsSubscription?.cancel();
    _productsSubscription = null;
  }
}
