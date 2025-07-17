import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/repo/cart_repo.dart';
import 'package:agrimarket/data/services/cart_service.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:get/get.dart';

class CartVm extends GetxController {
  final CartService _cartService;
  final Rx<Cart?> cart = Rx<Cart?>(null);
  final RxBool isLoading = false.obs;
  final RxInt itemCount = 1.obs;
  final Rx<Map<String, StoreModel>> store = Rx<Map<String, StoreModel>>({});
  final Rxn<ProductModel> product = Rxn<ProductModel>();
  final Set<String> _processingKeys = {};
  final isLoadingCart = true.obs;

  CartVm(CartRepository cartRepository) : _cartService = CartService(cartRepository);

  Future<void> loadCart() async {
    isLoadingCart.value = true;
    cart.value = await _cartService.loadCart();
    isLoadingCart.value = false;
  }

  Future<void> addItem({required ProductModel product, required StoreModel store, required int itemCount}) async {
    await _cartService.addItem(product: product, store: store, itemCount: itemCount);
    await loadCart();
  }

  Future<void> removeFromCart(CartItem item) async {
    await _cartService.removeFromCart(item);
    await loadCart();
  }

  Future<void> removeItemsByStoreId(String storeId) async {
    if (cart.value == null) return;

    final itemsToRemove = cart.value!.items.where((item) => item.storeId == storeId).toList();

    for (final item in itemsToRemove) {
      await _cartService.removeFromCart(item);
    }

    await loadCart();
  }

  Future<void> updateQuantity(String productId, String storeId, int newQuantity) async {
    await _cartService.updateQuantity(productId, storeId, newQuantity);
    await loadCart();
  }

  Map<String, List<CartItem>> groupCartByStore(List<CartItem> items) {
    return _cartService.groupCartByStore(items);
  }

  Future<void> decreaseQuantity(String productId, String storeId, int newQuantity, CartItem item) async {
    final key = '$productId|$storeId';
    if (_processingKeys.contains(key)) return;
    _processingKeys.add(key);
    try {
      final currentItem = cart.value?.items.firstWhereOrNull(
        (item) => item.productId == productId && item.storeId == storeId,
      );
      if (currentItem == null) return;
      if (currentItem.quantity <= 1) {
        await removeFromCart(item);
        return;
      }
      final updatedQuantity = currentItem.quantity - 1;
      await updateQuantity(productId, storeId, updatedQuantity.value);
    } finally {
      _processingKeys.remove(key);
    }
  }

  Future<void> increaseQuantity(String productId, String storeId, int newQuantity) async {
    final key = '$productId|$storeId';
    if (_processingKeys.contains(key)) return;
    _processingKeys.add(key);
    try {
      final currentItem = cart.value?.items.firstWhereOrNull(
        (item) => item.productId == productId && item.storeId == storeId,
      );
      if (currentItem == null) return;

      final product = await _cartService.loadProductById(productId);
      if (product == null) {
        Get.snackbar('Lỗi', 'Không tìm thấy sản phẩm');
        return;
      }

      final tempQuantity = currentItem.quantity.value + 1;

      if (tempQuantity > product.quantity) {
        Get.snackbar('Lỗi', 'Sản phẩm chỉ còn ${product.quantity} cái trong kho');
        return;
      }

      // Chỉ update khi hợp lệ
      await updateQuantity(productId, storeId, tempQuantity);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tăng số lượng');
    } finally {
      _processingKeys.remove(key);
    }
  }

  Future<void> loadStorebyId(String storeId) async {
    final loadedStore = await _cartService.loadStoreById(storeId);
    if (loadedStore != null) {
      final newMap = Map<String, StoreModel>.from(store.value);
      newMap[storeId] = loadedStore;
      store.value = newMap; 
    }
  }

  Future<void> loadProductbyId(String productId) async {
    product.value = await _cartService.loadProductById(productId);
  }

  double getTotalPriceByStore(String storeId) {
    return _cartService.getTotalPriceByStore(storeId, cart.value);
  }

  int getTotalQuantity(String storeId) {
    return _cartService.getTotalQuantity(storeId, cart.value);
  }

  double getTotalDiscountByStore(String storeId) {
    return _cartService.getTotalDiscountByStore(storeId, cart.value);
  }

  void clearCache() {
    _cartService.clearAllCache();
  }
}
