import 'package:agrimarket/data/models/menu.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/data/services/store_detail_service.dart';
import 'package:get/get.dart';

class StoreDetailVm extends GetxController {
  final RxBool isLoading = false.obs;
  final StoreDetailService _storeDetailService = StoreDetailService();

  final RxString _currentStoreId = ''.obs;

  // Getters
  MenuModel? getMenuForStore(String storeId) => _storeDetailService.getMenuForStore(storeId);
  List<ProductModel>? getProductsForStore(String storeId) => _storeDetailService.getProductsForStore(storeId);
  ProductPromotionModel? getPromotion(String promotionId) => _storeDetailService.getPromotion(promotionId);

  Future<void> loadStoreData(String storeId) async {
    _currentStoreId.value = storeId;
    isLoading.value = true;
    try {
      await _storeDetailService.loadStoreData(storeId);
    } finally {
      isLoading.value = false;
    }
  }

  List<ProductModel> filterProductsByIds(List<String> ids) {
    return _storeDetailService.filterProductsByIds(ids, _currentStoreId.value);
  }

  Future<void> refreshStoreData(String storeId) async {
    await _storeDetailService.refreshStoreData(storeId);
  }

  ProductPromotionModel? getDiscountInfoSync(String discountId) {
    return _storeDetailService.getDiscountInfoSync(discountId);
  }

  Future<ProductPromotionModel?> getDiscountInfo(String discountId) async {
    return await _storeDetailService.getDiscountInfo(discountId);
  }

  @override
  void onClose() {
    _storeDetailService.dispose();
    super.onClose();
  }
}
