import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/repo/cart_repo.dart';
import 'package:agrimarket/data/repo/product_repo.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CartVm extends GetxController {
  final CartRepository _cartRepository;
  final Rx<Cart?> cart = Rx<Cart?>(null);
  final RxBool isLoading = false.obs;
  final RxInt itemCount = 1.obs;
  final Rxn<StoreModel> store = Rxn<StoreModel>();
  final Rxn<ProductModel> product = Rxn<ProductModel>();
  final StoreService storeService = StoreService();
  final ProductRepository productRepository = ProductRepository();

  CartVm(this._cartRepository);

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  Future<ProductModel?> fetchProduct(String productId) async {
    final doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
    if (!doc.exists) return null;
    return ProductModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<void> loadCart() async {
    if (userId == null) {
      Get.snackbar('Lỗi', 'Người dùng chưa đăng nhập');
      return;
    }

    try {
      final loadedCart = await _cartRepository.getCart(userId!);

      if (loadedCart != null) {
        final futures = loadedCart.items.map((item) => fetchProduct(item.productId));
        final productList = await Future.wait(futures);

        for (int i = 0; i < loadedCart.items.length; i++) {
          final product = productList.elementAt(i);
          if (product != null) {
            loadedCart.items[i].isOnSaleAtAddition = product.isOnSale;
          }
        }
      }

      cart.value = loadedCart;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải giỏ hàng: $e');
    }
  }

  Future<void> addItem({required ProductModel product, required StoreModel store, required int itemCount}) async {
    try {
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
        ),
      );
      await loadCart();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm vào giỏ hàng');
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    try {
      await _cartRepository.removeItems(userId!, item);
      await loadCart();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa sản phẩm khỏi giỏ hàng');
    }
  }

  Future<void> updateQuantity(String productId, String storeId, int newQuantity) async {
    try {
      await _cartRepository.updateCartItemQuantity(
        userId: userId!,
        productId: productId,
        storeId: storeId,
        newQuantity: newQuantity,
      );
      await loadCart();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật số lượng');
    }
  }

  Map<String, List<CartItem>> groupCartByStore(List<CartItem> items) {
    final Map<String, List<CartItem>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.storeId, () => []).add(item);
    }
    return grouped;
  }

  Future<void> decreaseQuantity(String productId, String storeId, int newQuantity, CartItem item) async {
    final currentItem = cart.value?.items.firstWhereOrNull(
      (item) => item.productId == productId && item.storeId == storeId,
    );

    if (currentItem == null) return;

    final updatedQuantity = currentItem.quantity - 1;

    if (updatedQuantity < 1) {
      await removeFromCart(item);
    }

    await updateQuantity(productId, storeId, updatedQuantity.value);
  }

  Future<void> increaseQuantity(String productId, String storeId, int newQuantity) async {
    final currentItem = cart.value?.items.firstWhereOrNull(
      (item) => item.productId == productId && item.storeId == storeId,
    );

    if (currentItem == null) return;

    final updatedQuantity = currentItem.quantity + 1;

    await updateQuantity(productId, storeId, updatedQuantity.value);
  }

  Future<void> loadStorebyId(String storeId) async {
    store.value = await storeService.fetchStoresbyID(storeId);
  }

  Future<void> loadProductbyId(String productId) async {
    product.value = await productRepository.getProductById(productId);
  }

  double getTotalPriceByStore(String storeId) {
    final filteredItems = cart.value?.items.where((item) => item.storeId == storeId) ?? [];

    double total = 0;
    for (var item in filteredItems) {
      final price =
          (item.isOnSaleAtAddition ?? false) ? (item.promotionPrice ?? item.priceAtAddition) : item.priceAtAddition;
      total += price * item.quantity.value;
    }
    return total;
  }

  // int getTotalDiscountByStore(String storeId) {
  //   final filteredItems = cart.value?.items.where((item) => item.storeId == storeId) ?? [];

  //   int discount = 0;
  //   for (var item in filteredItems) {
  //     if ((item.isOnSaleAtAddition ?? false) && item.promotionPrice != null) {
  //       discount += (item.priceAtAddition - item.promotionPrice!) * item.quantity.value;
  //     }
  //   }
  //   return discount;
  // }
}
