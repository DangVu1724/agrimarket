import 'package:agrimarket/data/models/menu.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/repo/store_repo.dart';
import 'package:agrimarket/data/services/menu_service.dart';
import 'package:agrimarket/data/services/product_service.dart';
import 'package:agrimarket/data/services/promotion_service.dart';
import 'package:get/get.dart';

class StoreDetailService {
  final MenuService _menuService = MenuService();
  final ProductService _productService = ProductService();
  final PromotionService _promotionService = PromotionService();
  final StoreRepository _storeRepository = StoreRepository();
  final RxMap<String, MenuModel> _menuCache = <String, MenuModel>{}.obs;
  final RxMap<String, List<ProductModel>> _productsCache = <String, List<ProductModel>>{}.obs;
  final RxMap<String, ProductPromotionModel> _promotionsCache = <String, ProductPromotionModel>{}.obs;

  // Getters
  MenuModel? getMenuForStore(String storeId) => _menuCache[storeId];
  List<ProductModel>? getProductsForStore(String storeId) => _productsCache[storeId];
  ProductPromotionModel? getPromotion(String promotionId) => _promotionsCache[promotionId];

  // Load tất cả dữ liệu cho store
  Future<void> loadStoreData(String storeId) async {
    try {
      // Load menu và products song song
      final results = await Future.wait([
        _menuService.getMenuForStore(storeId),
        _productService.fetchProductListByStore(storeId),
      ]);

      final menu = results[0] as MenuModel?;
      final products = results[1] as List<ProductModel>;

      // Cập nhật cache
      if (menu != null) {
        _menuCache[storeId] = menu;
      }
      _productsCache[storeId] = products;

      // Load promotions cho các sản phẩm có promotion
      final promotionIds = products.where((p) => p.promotion != null).map((p) => p.promotion!).toSet().toList();

      if (promotionIds.isNotEmpty) {
        await _promotionService.loadMultiplePromotions(promotionIds);
        // Cập nhật promotion cache từ service
        for (final id in promotionIds) {
          final promotion = _promotionService.getDiscountInfoSync(id);
          if (promotion != null) {
            _promotionsCache[id] = promotion;
          }
        }
      }

      // Bắt đầu realtime listener cho products
      _productService.listenToProducts(storeId);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải dữ liệu cửa hàng: $e');
    }
  }

  // Refresh dữ liệu
  Future<void> refreshStoreData(String storeId) async {
    // Xóa cache
    _menuService.clearMenuCacheForStore(storeId);
    _productService.clearProductCacheForStore(storeId);

    final products = _productsCache[storeId] ?? [];
    final promotionIds = products.where((p) => p.promotion != null).map((p) => p.promotion!).toSet().toList();

    for (final id in promotionIds) {
      _promotionService.clearPromotionCache(id);
    }

    // Xóa local cache
    _menuCache.remove(storeId);
    _productsCache.remove(storeId);
    for (final id in promotionIds) {
      _promotionsCache.remove(id);
    }

    // Load lại
    await loadStoreData(storeId);
  }

  // Filter products theo IDs
  List<ProductModel> filterProductsByIds(List<String> ids, String storeId) {
    return _productService.filterProductsByIds(ids, storeId);
  }

  // Lấy promotion info
  ProductPromotionModel? getDiscountInfoSync(String discountId) {
    return _promotionsCache[discountId];
  }

  Future<ProductPromotionModel?> getDiscountInfo(String discountId) async {
    return await _promotionService.getDiscountInfo(discountId);
  }

  Future<List<Review>> fetchReviewsForStore(String storeId) async {
    return await _storeRepository.fetchReviewsForStore(storeId);
  }

  // Dispose
  void dispose() {
    _productService.dispose();
    _promotionService.dispose();
  }
}
