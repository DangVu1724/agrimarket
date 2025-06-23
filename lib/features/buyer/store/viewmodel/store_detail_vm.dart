import 'package:agrimarket/data/models/menu.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/data/repo/menu_repo.dart';
import 'package:agrimarket/data/repo/product_repo.dart';
import 'package:agrimarket/data/services/promotion_service.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class StoreDetailVm extends GetxController {
  final RxBool isLoading = false.obs;
  final MenuRepository _menuRepository = MenuRepository();
  final ProductRepository _productRepository = ProductRepository();
  final PromotionService _promotionService = PromotionService();
  final Box _cacheBox = Hive.box('storeCache');

  // Sử dụng Map để lưu trữ dữ liệu cho nhiều cửa hàng
  final RxMap<String, MenuModel> _menuCache = <String, MenuModel>{}.obs;
  final RxMap<String, List<ProductModel>> _productsCache =
      <String, List<ProductModel>>{}.obs;
  final RxMap<String, ProductPromotionModel> _promotionsCache =
      <String, ProductPromotionModel>{}.obs;

  // Lấy dữ liệu từ cache
  MenuModel? getMenuForStore(String storeId) => _menuCache[storeId];
  List<ProductModel>? getProductsForStore(String storeId) =>
      _productsCache[storeId];

  final RxString _currentStoreId = ''.obs;

  // Load dữ liệu cho cửa hàng
  Future<void> loadStoreData(String storeId) async {
    _currentStoreId.value = storeId;
    isLoading.value = true;
    try {
      await Future.wait([_loadMenu(storeId), _loadProducts(storeId)]);

      final products = _productsCache[storeId] ?? [];
      final promotionIds =
          products
              .where((p) => p.promotion != null)
              .map((p) => p.promotion!)
              .toSet()
              .toList();

      await _loadMultiplePromotions(promotionIds);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMultiplePromotions(List<String> promotionIds) async {
    if (promotionIds.isEmpty) return;

    final idsToLoad =
        promotionIds.where((id) => !_promotionsCache.containsKey(id)).toList();
    if (idsToLoad.isEmpty) return;

    try {
      final promotions = await Future.wait(
        idsToLoad.map((id) => _loadPromotion(id)),
      );

      // Lưu vào cache
      for (int i = 0; i < idsToLoad.length; i++) {
        if (promotions[i] != null) {
          _promotionsCache[idsToLoad[i]] = promotions[i]!;
        }
      }
    } catch (e) {
      print('Error loading multiple promotions: $e');
    }
  }

  Future<ProductPromotionModel?> _loadPromotion(String promotionId) async {
    try {
      final promotion = await _promotionService.getDiscountInfo(promotionId);
      return (promotion != null && promotion.isValid) ? promotion : null;
    } catch (e) {
      print('Error loading promotion: $e');
      return null;
    }
  }

  Future<void> _loadMenu(String storeId) async {
    final cachedMenu = _cacheBox.get('menu_$storeId');
    final cacheTimestamp = _cacheBox.get('menu_${storeId}_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;
    const cacheDuration = 10 * 60 * 1000; // 10 phút

    if (cachedMenu != null &&
        cacheTimestamp != null &&
        now - cacheTimestamp < cacheDuration) {
      try {
        final parsedMenu = MenuModel.fromJson(
          Map<String, dynamic>.from(cachedMenu),
        );
        _menuCache[storeId] = parsedMenu;
        return;
      } catch (e) {
        print('Error parsing cached menu for store $storeId: $e');
        await _cacheBox.delete('menu_$storeId');
        await _cacheBox.delete('menu_${storeId}_timestamp');
      }
    }

    try {
      final menu = await _menuRepository.fetchMenu(storeId);
      if (menu != null) {
        _menuCache[storeId] = menu;
        await _cacheBox.put('menu_$storeId', menu.toJson());
        await _cacheBox.put('menu_${storeId}_timestamp', now);
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải menu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      _menuCache.remove(storeId);
    }
  }

  Future<void> _loadProducts(String storeId) async {
    final cachedProducts = _cacheBox.get('products_$storeId');
    final cacheTimestamp = _cacheBox.get('products_${storeId}_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;
    const cacheDuration = 10 * 60 * 1000; // 10 phút

    if (cachedProducts != null &&
        cacheTimestamp != null &&
        now - cacheTimestamp < cacheDuration) {
      try {
        final parsedProducts =
            (cachedProducts as List<dynamic>)
                .map((p) => ProductModel.fromJson(Map<String, dynamic>.from(p)))
                .toList();
        _productsCache[storeId] = parsedProducts;
        return;
      } catch (e) {
        await _cacheBox.delete('products_$storeId');
        await _cacheBox.delete('products_${storeId}_timestamp');
      }
    }

    try {
      final products = await _productRepository.fetchProductsByStoreId(storeId);
      if (products.isNotEmpty) {
        _productsCache[storeId] = products;
        await _cacheBox.put(
          'products_$storeId',
          products.map((p) => p.toJson()).toList(),
        );
        await _cacheBox.put('products_${storeId}_timestamp', now);
      } else {
        _productsCache.remove(storeId);
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải sản phẩm: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      _productsCache.remove(storeId);
    }
  }

  Future<ProductPromotionModel?> getDiscountInfo(String discountId) async {
    // 1. Kiểm tra cache
    if (_promotionsCache.containsKey(discountId)) {
      final cachedPromo = _promotionsCache[discountId]!;

      if (!cachedPromo.isValid) {
        _promotionsCache.remove(discountId);
        return null;
      }
      return cachedPromo;
    }

    // 2. Load từ Firestore
    final promotion = await _loadPromotion(discountId);
    if (promotion == null || !promotion.isValid) return null;

    // 3. Lưu vào cache nếu hợp lệ
    _promotionsCache[discountId] = promotion;
    return promotion;
  }

  List<ProductModel> filterProductsByIds(List<String> ids) {
    final currentProducts = _productsCache[_currentStoreId.value] ?? [];
    return currentProducts.where((p) => ids.contains(p.id)).toList();
  }

  Future<void> refreshStoreData(String storeId) async {
    // Xóa cache local
    await _cacheBox.delete('menu_$storeId');
    await _cacheBox.delete('menu_${storeId}_timestamp');
    await _cacheBox.delete('products_$storeId');
    await _cacheBox.delete('products_${storeId}_timestamp');

    // Xác định các promotionId cần xóa
    final products = _productsCache[storeId] ?? [];
    final promotionIds =
        products
            .where((p) => p.promotion != null)
            .map((p) => p.promotion!)
            .toSet()
            .toList();

    // Xóa cache promotion
    for (final id in promotionIds) {
      await _cacheBox.delete('promotion_$id');
      await _cacheBox.delete('promotion_${id}_timestamp');
      _promotionsCache.remove(id);
    }

    // Xóa cache bộ nhớ
    _menuCache.remove(storeId);
    _productsCache.remove(storeId);

    // Load lại dữ liệu
    await loadStoreData(storeId);
  }
}
