import 'package:agrimarket/data/models/menu.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/data/repo/menu_repo.dart';
import 'package:agrimarket/data/repo/product_repo.dart';
import 'package:agrimarket/data/services/promotion_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'dart:async';

class StoreDetailVm extends GetxController {
  final RxBool isLoading = false.obs;
  final MenuRepository _menuRepository = MenuRepository();
  final ProductRepository _productRepository = ProductRepository();
  final PromotionService _promotionService = PromotionService();
  final Box _cacheBox = Hive.box('storeCache');

  final RxMap<String, MenuModel> _menuCache = <String, MenuModel>{}.obs;
  final RxMap<String, List<ProductModel>> _productsCache =
      <String, List<ProductModel>>{}.obs;
  final RxMap<String, ProductPromotionModel> _promotionsCache =
      <String, ProductPromotionModel>{}.obs;

  MenuModel? getMenuForStore(String storeId) => _menuCache[storeId];
  List<ProductModel>? getProductsForStore(String storeId) =>
      _productsCache[storeId];

  final RxString _currentStoreId = ''.obs;
  Timer? _promotionTimer;
  StreamSubscription? _productsSubscription;

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
      listenToProducts(storeId);
    } finally {
      isLoading.value = false;
    }
  }

  void listenToProducts(String storeId) {
    _productsSubscription?.cancel();
    _productsSubscription = FirebaseFirestore.instance
        .collection('products')
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .listen(
          (snapshot) {
            _productsCache[storeId] =
                snapshot.docs
                    .map(
                      (doc) =>
                          ProductModel.fromJson({...doc.data(), 'id': doc.id}),
                    )
                    .toList();
            final promotionIds =
                _productsCache[storeId]!
                    .where((p) => p.promotion != null)
                    .map((p) => p.promotion!)
                    .toSet()
                    .toList();
            _loadMultiplePromotions(promotionIds);
            print(
              'Stream updated ${snapshot.docs.length} products for store $storeId',
            );
          },
          onError: (e) {
            print('Stream error: $e');
            Get.snackbar('Lỗi', 'Không thể đồng bộ sản phẩm: $e');
          },
        );
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
      print('Loaded promotion $promotionId: ${promotion?.toJson()}');
      return promotion;
    } catch (e) {
      print('Error loading promotion $promotionId: $e');
      return null;
    }
  }

  ProductPromotionModel? getDiscountInfoSync(String discountId) {
    return _promotionsCache[discountId];
  }

  Future<ProductPromotionModel?> getDiscountInfo(String discountId) async {
    if (_promotionsCache.containsKey(discountId)) {
      return _promotionsCache[discountId];
    }
    final promotion = await _loadPromotion(discountId);
    if (promotion != null) {
      _promotionsCache[discountId] = promotion;
      return promotion;
    }
    return null;
  }

  Future<void> _loadMenu(String storeId) async {
    final cachedMenu = _cacheBox.get('menu_$storeId');
    final cacheTimestamp = _cacheBox.get('menu_${storeId}_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;
    const cacheDuration = 10 * 60 * 1000;

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
    const cacheDuration = 10 * 60 * 1000;

    if (cachedProducts != null &&
        cacheTimestamp != null &&
        now - cacheTimestamp < cacheDuration) {
      try {
        final parsedProducts =
            (cachedProducts as List<dynamic>)
                .map((p) => ProductModel.fromJson(Map<String, dynamic>.from(p)))
                .toList();
        _productsCache[storeId] = parsedProducts;
        print(
          'Loaded ${parsedProducts.length} products from cache for store $storeId',
        );
        return;
      } catch (e) {
        print('Error parsing cached products: $e');
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
        print('Saved ${products.length} products to cache for store $storeId');
      } else {
        _productsCache.remove(storeId);
      }
    } catch (e) {
      print('Error fetching products: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tải sản phẩm: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      _productsCache.remove(storeId);
    }
  }

  List<ProductModel> filterProductsByIds(List<String> ids) {
    final currentProducts = _productsCache[_currentStoreId.value] ?? [];
    final filteredProducts =
        currentProducts.where((p) => ids.contains(p.id)).toList();
    return filteredProducts;
  }

  Future<void> refreshStoreData(String storeId) async {
    await _cacheBox.delete('menu_$storeId');
    await _cacheBox.delete('menu_${storeId}_timestamp');
    await _cacheBox.delete('products_$storeId');
    await _cacheBox.delete('products_${storeId}_timestamp');
    final products = _productsCache[storeId] ?? [];
    final promotionIds =
        products
            .where((p) => p.promotion != null)
            .map((p) => p.promotion!)
            .toSet()
            .toList();
    for (final id in promotionIds) {
      await _cacheBox.delete('promotion_$id');
      await _cacheBox.delete('promotion_${id}_timestamp');
      _promotionsCache.remove(id);
    }
    _menuCache.remove(storeId);
    _productsCache.remove(storeId);
    await loadStoreData(storeId);
  }

  void _startPromotionCheckTimer() {
    _promotionTimer?.cancel();
    _promotionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final expiredProducts =
          _productsCache.values
              .expand((products) => products)
              .where((p) => p.promotion != null && !p.isOnSale)
              .toList();
      if (expiredProducts.isNotEmpty) {
        for (var product in expiredProducts) {
          _productsCache[product.storeId] =
              _productsCache[product.storeId]!
                  .map(
                    (p) =>
                        p.id == product.id
                            ? p.copyWith(
                              promotion: null,
                              promotionPrice: null,
                              promotionEndDate: null,
                            )
                            : p,
                  )
                  .toList();
        }
        print('Cleared ${expiredProducts.length} expired promotions');
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    _startPromotionCheckTimer();
  }

  @override
  void onClose() {
    _promotionTimer?.cancel();
    _productsSubscription?.cancel();
    super.onClose();
  }
}
