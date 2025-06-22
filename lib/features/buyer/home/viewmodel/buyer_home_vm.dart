import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/product_filter_service.dart';
import 'package:get/get.dart';

class BuyerHomeScreenVm extends GetxController {
  final _productService = ProductFilterService();

  var products = <ProductModel>[].obs;
  var store = Rxn<StoreModel>();
  var isLoading = false.obs;

  Future<void> loadProductsByStore(String storeId) async {
    isLoading.value = true;
    try {
      final result = await _productService.fetchProductListByStore(storeId);
      // final store = await _storeService.fetchStoresbyID(storeId);
      products.value = result;
      

    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải sản phẩm: $e');
    } finally {
      isLoading.value = false;
    }
  }
}