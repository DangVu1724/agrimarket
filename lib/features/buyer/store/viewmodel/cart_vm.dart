import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/repo/cart_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CartVm extends GetxController {
  final CartRepository _cartRepository;
  final Rx<Cart?> cart = Rx<Cart?>(null);
  final RxBool isLoading = false.obs;
  final RxInt itemCount = 1.obs;

  CartVm(this._cartRepository);

  String? get userId => FirebaseAuth.instance.currentUser?.uid;


  Future<void> loadCart() async {
    if (userId == null) {
      Get.snackbar('Lỗi', 'Người dùng chưa đăng nhập');
      return;
    }
    
    try {
      cart.value = await _cartRepository.getCart(userId!);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải giỏ hàng');
    }
  }

  Future<void> addItem({
    required ProductModel product,
    required StoreModel store,
    required int itemCount,
  }) async {
    try {
      if(product.promotion != null) {
        // Kiểm tra xem sản phẩm có chương trình khuyến mãi hay không
        // final type = product.promotion!['discountType'];
      }

      await _cartRepository.addToCart(
        userId!,
        CartItem(
          productId: product.id,
          storeId: store.storeId,
          quantity: itemCount,
          priceAtAddition: product.price,
          productName: product.name,
          productImage: product.imageUrl,
        ),
      );
      await loadCart();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm vào giỏ hàng');
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

  
}