import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/product_service.dart';
import 'package:get/get.dart';

class BuyerHomeScreenVm extends GetxController {
  final _productService = ProductService();

  var products = <ProductModel>[].obs;
  var store = Rxn<StoreModel>();
  var isLoading = false.obs;



  Future<void> loadProductsByStore(String storeId) async {
    isLoading.value = true;
    try {
      // Kiểm tra cache trước
      final cachedProducts = _productService.getProductsFromCache(storeId);
      if (cachedProducts != null) {
        products.value = cachedProducts;
        isLoading.value = false;
        return;
      }

      // Nếu không có cache, load từ API
      final result = await _productService.fetchProductListByStore(storeId);
      products.value = result;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải sản phẩm: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Xóa cache cho store cụ thể
  void clearCacheForStore(String storeId) {
    _productService.clearProductCacheForStore(storeId);
  }

  // Refresh data (xóa cache và load lại)
  Future<void> refreshProductsByStore(String storeId) async {
    clearCacheForStore(storeId);
    await loadProductsByStore(storeId);
  }
}
