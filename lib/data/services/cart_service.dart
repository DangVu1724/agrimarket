import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/repo/cart_repo.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CartService {
  final CartRepository _cartRepository;
  final StoreService _storeService = StoreService();

  // RAM cache (session only)
  final RxMap<String, Cart> _cartCache = <String, Cart>{}.obs;
  final RxMap<String, ProductModel> _productCache = <String, ProductModel>{}.obs;
  final RxMap<String, StoreModel> _storeCache = <String, StoreModel>{}.obs;

  CartService(this._cartRepository);

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // Load cart (RAM cache only)
  Future<Cart?> loadCart() async {
    if (userId == null) {
      Get.snackbar('Lỗi', 'Người dùng chưa đăng nhập');
      return null;
    }

    try {
      final loadedCart = await _cartRepository.getCart(userId!);

      if (loadedCart != null) {
        await _loadProductInfoForCart(loadedCart);
        _cartCache[userId!] = loadedCart;
      }

      return loadedCart;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải giỏ hàng: $e');
      return null;
    }
  }

  // Load product info cho cart items
  Future<void> _loadProductInfoForCart(Cart cart) async {
    final futures = cart.items.map((item) => _fetchProduct(item.productId));
    final productList = await Future.wait(futures);

    for (int i = 0; i < cart.items.length; i++) {
      final product = productList.elementAt(i);
      if (product != null) {
        cart.items[i].isOnSaleAtAddition = product.isOnSale;
        _productCache[product.id] = product;
      }
    }
  }

  // Fetch product với cache
  Future<ProductModel?> _fetchProduct(String productId) async {
    // Kiểm tra cache trước
    if (_productCache.containsKey(productId)) {
      return _productCache[productId];
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
      if (!doc.exists) return null;

      final product = ProductModel.fromJson({...doc.data()!, 'id': doc.id});
      _productCache[productId] = product;
      return product;
    } catch (e) {
      return null;
    }
  }

  // Add item to cart
  Future<void> addItem({required ProductModel product, required StoreModel store, required int itemCount}) async {
    if (userId == null) return;

    try {
      final currentCart = await loadCart();
      final existingItem = currentCart?.items.firstWhereOrNull(
        (item) => item.productId == product.id && item.storeId == store.storeId,
      );

      final currentQtyInCart = existingItem?.quantity.value ?? 0;
    final totalRequestedQty = currentQtyInCart + itemCount;

    if (product.quantity < totalRequestedQty) {
      Get.snackbar('Lỗi', 'Sản phẩm chỉ còn ${product.quantity} cái trong kho');
      return;
    }


      if (existingItem != null) {
        await updateQuantity(product.id, store.storeId, existingItem.quantity.value + itemCount);
        return;
      } else {
        await _cartRepository.addToCart(
          userId!,
          CartItem(
            productId: product.id,
            storeId: store.storeId,
            quantity: itemCount,
            priceAtAddition: product.price,
            promotionPrice: product.promotionPrice,
            productName: product.name,
            productImage: product.imageUrl,
            storeName: store.name,
            isOnSaleAtAddition: product.isOnSale,
            unit: product.unit,
          ),
        );
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm vào giỏ hàng');
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(CartItem item) async {
    if (userId == null) return;

    try {
      await _cartRepository.removeItems(userId!, item);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa sản phẩm khỏi giỏ hàng');
    }
  }

  // Update quantity
  Future<void> updateQuantity(String productId, String storeId, int newQuantity) async {
    if (userId == null) return;

    try {
      await _cartRepository.updateCartItemQuantity(
        userId: userId!,
        productId: productId,
        storeId: storeId,
        newQuantity: newQuantity,
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật số lượng');
    }
  }

  // Load store by ID với cache
  Future<StoreModel?> loadStoreById(String storeId) async {
    // Kiểm tra cache trước
    if (_storeCache.containsKey(storeId)) {
      return _storeCache[storeId];
    }

    try {
      final store = await _storeService.fetchStoresbyID(storeId);
      if (store != null) {
        _storeCache[storeId] = store;
      }
      return store;
    } catch (e) {
      print('Error loading store $storeId: $e');
      return null;
    }
  }

  // Load product by ID với cache
  Future<ProductModel?> loadProductById(String productId) async {
    return await _fetchProduct(productId);
  }

  // Group cart by store
  Map<String, List<CartItem>> groupCartByStore(List<CartItem> items) {
    final Map<String, List<CartItem>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.storeId, () => []).add(item);
    }
    return grouped;
  }

  // Calculate total price by store
  double getTotalPriceByStore(String storeId, Cart? cart) {
    final filteredItems = cart?.items.where((item) => item.storeId == storeId) ?? [];

    double total = 0;
    for (var item in filteredItems) {
      final price =
          (item.isOnSaleAtAddition ?? false) ? (item.promotionPrice ?? item.priceAtAddition) : item.priceAtAddition;
      total += price * item.quantity.value;
    }
    return total;
  }

  // Calculate total quantity by store
  int getTotalQuantity(String storeId, Cart? cart) {
    final filteredItems = cart?.items.where((item) => item.storeId == storeId) ?? [];

    int totalQuantity = 0;
    for (var item in filteredItems) {
      totalQuantity += item.quantity.value;
    }
    return totalQuantity;
  }

  // Calculate total discount by store
  double getTotalDiscountByStore(String storeId, Cart? cart) {
    final filteredItems = cart?.items.where((item) => item.storeId == storeId) ?? [];

    double discount = 0;
    for (var item in filteredItems) {
      if ((item.isOnSaleAtAddition ?? false) && item.promotionPrice != null) {
        discount += (item.priceAtAddition - item.promotionPrice!) * item.quantity.value;
      }
    }
    return discount;
  }

  // Clear all RAM cache
  void clearAllCache() {
    _cartCache.clear();
    _productCache.clear();
    _storeCache.clear();
  }
}
