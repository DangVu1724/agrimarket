import 'package:agrimarket/data/models/discount_code.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/data/repo/product_repo.dart';
import 'package:agrimarket/data/services/promotion_service.dart';
import 'package:agrimarket/features/seller/product/viewmodel/seller_product_screen_vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PromotionVm extends GetxController {
  final PromotionService _promotionService = PromotionService();

  // Dùng Rx<List<...>> thay vì RxList<>
  final Rx<List<ProductPromotionModel>> productDiscounts = Rx<List<ProductPromotionModel>>([]);
  final Rx<List<DiscountCodeModel>> discountCodes = Rx<List<DiscountCodeModel>>([]);
  final Rx<List<ProductModel>> allProducts = Rx<List<ProductModel>>([]);

  SellerProductVm get productVm => Get.find<SellerProductVm>();

  final RxBool isLoading = false.obs;

  Future<void> loadAllPromotions(String storeId) async {
    isLoading.value = true;
    try {
      final discounts = await _promotionService.getProductDiscounts(storeId);
      final codes = await _promotionService.getDiscountCodes(storeId);

      productDiscounts.value = discounts;
      discountCodes.value = codes;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải khuyến mãi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllProducts(String storeId) async {
    try {
      final products = await ProductRepository().fetchProductsByStoreId(storeId);
      allProducts.value = products;
    } catch (e) {
      print("Lỗi khi load sản phẩm: $e");
    }
  }

  Future<void> addProductDiscount(ProductPromotionModel discount) async {
    try {
      await _promotionService.createProductDiscount(discount);
      final currentList = productDiscounts.value;
      productDiscounts.value = [...currentList, discount];
    } catch (e) {
      Get.snackbar('Lỗi', 'Thêm khuyến mãi thất bại: $e');
    }
  }

  Future<void> deleteProductDiscount(String id) async {
    try {
      await _promotionService.removeProductDiscount(id);
      final currentList = productDiscounts.value;
      productDiscounts.value = currentList.where((e) => e.id != id).toList();
    } catch (e) {
      Get.snackbar('Lỗi', 'Xóa khuyến mãi thất bại: $e');
    }
  }

  Future<void> addDiscountCode(DiscountCodeModel code) async {
    try {
      await _promotionService.createDiscountCode(code);
      final currentList = discountCodes.value;
      discountCodes.value = [...currentList, code];
    } catch (e) {
      Get.snackbar('Lỗi', 'Thêm mã giảm giá thất bại: $e');
    }
  }

  Future<void> deleteDiscountCode(String id) async {
    try {
      await _promotionService.removeDiscountCode(id);
      final currentList = discountCodes.value;
      discountCodes.value = currentList.where((e) => e.id != id).toList();
    } catch (e) {
      Get.snackbar('Lỗi', 'Xóa mã giảm giá thất bại: $e');
    }
  }

  Future<void> addProductToDiscount(String discountId, String productId) async {
    try {
      await _promotionService.addProductToDiscount(discountId, productId);

      final currentList = productDiscounts.value;
      final index = currentList.indexWhere((e) => e.id == discountId);
      if (index != -1) {
        final oldPromotion = currentList[index];
        final newProductIds = [...oldPromotion.productIds, productId];
        final updatedPromotion = oldPromotion.copyWith(productIds: newProductIds);

        final newList = [...currentList];
        newList[index] = updatedPromotion;
        productDiscounts.value = newList;
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Thêm sản phẩm vào khuyến mãi thất bại: $e');
    }
  }

  Future<void> removeProductFromDiscount(String discountId, String productId) async {
    try {
      await _promotionService.removeProductFromDiscount(discountId, productId);

      final currentList = productDiscounts.value;
      final index = currentList.indexWhere((e) => e.id == discountId);
      if (index != -1) {
        final oldPromotion = currentList[index];
        final newProductIds = oldPromotion.productIds.where((id) => id != productId).toList();
        final updatedPromotion = oldPromotion.copyWith(productIds: newProductIds);

        final newList = [...currentList];
        newList[index] = updatedPromotion;
        productDiscounts.value = newList;
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Xóa sản phẩm khỏi khuyến mãi thất bại: $e');
    }
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (doc.exists) {
        return ProductModel.fromJson(doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
