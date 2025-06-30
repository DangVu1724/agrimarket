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
  final ProductRepository _productRepository = ProductRepository();
  final SellerProductVm productVm = Get.find<SellerProductVm>();

  final Rx<List<ProductPromotionModel>> productDiscounts = Rx<List<ProductPromotionModel>>([]);
  final Rx<List<DiscountCodeModel>> discountCodes = Rx<List<DiscountCodeModel>>([]);
  final Rx<List<ProductModel>> allProducts = Rx<List<ProductModel>>([]);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(productDiscounts, (_) => _syncProductsWithDiscounts());
  }

  Future<void> loadAllPromotions(String storeId) async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _promotionService.getProductDiscounts(storeId),
        _promotionService.getDiscountCodes(storeId),
        _productRepository.fetchProductsByStoreId(storeId),
      ]);

      productDiscounts.value = results[0] as List<ProductPromotionModel>;
      discountCodes.value = results[1] as List<DiscountCodeModel>;
      allProducts.value = results[2] as List<ProductModel>;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải dữ liệu khuyến mãi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addDiscountCode(DiscountCodeModel code) async {
    try {
      await _promotionService.createDiscountCode(code);

      await loadAllPromotions(code.storeId!);
    } catch (e) {
      Get.snackbar('Lỗi', 'Tạo khuyến mãi thất bại: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> addProductDiscount(ProductPromotionModel discount) async {
    try {
      await _promotionService.createProductDiscount(discount);

      await loadAllPromotions(discount.storeId);
    } catch (e) {
      Get.snackbar('Lỗi', 'Tạo khuyến mãi thất bại: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteProductDiscount(String? id) async {
    try {
      if (id == null || id.isEmpty) {
        throw Exception('ID khuyến mãi không hợp lệ');
      }
      final discount = productDiscounts.value.firstWhereOrNull((e) => e.id == id);
      if (discount == null) {
        throw Exception('Không tìm thấy khuyến mãi với ID: $id');
      }

      await _removeDiscountFromProducts(discount.productIds);
      await _promotionService.removeProductDiscount(id);

      productDiscounts.value = productDiscounts.value.where((e) => e.id != id).toList();
    } catch (e) {
      Get.snackbar('Lỗi', 'Xóa khuyến mãi thất bại: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
      rethrow;
    }
  }

  Future<void> addProductToDiscount(String discountId, String productId) async {
    try {
      final results = await Future.wait([
        _promotionService.getDiscountInfo(discountId),
        _productRepository.getProductById(productId),
      ]);

      final promotion = results[0] as ProductPromotionModel?;
      final product = results[1] as ProductModel?;

      if (promotion == null || product == null) {
        throw Exception('Không tìm thấy khuyến mãi hoặc sản phẩm');
      }

      _validateProductForDiscount(product, discountId);

      final discountedPrice = _calculateDiscountedPrice(
        price: product.price,
        discountValue: promotion.discountValue,
        discountType: promotion.discountType,
      );

      await _applyDiscountToProduct(discountId, productId, discountedPrice, promotion.endDate);
    } catch (e) {
      Get.snackbar('Lỗi', 'Thêm sản phẩm vào khuyến mãi thất bại: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> removeProductFromDiscount(String discountId, String productId) async {
    try {
      await Future.wait([
        _promotionService.removeProductFromDiscount(discountId, productId),
        FirebaseFirestore.instance.collection('products').doc(productId).update({
          'promotion': FieldValue.delete(),
          'price': FieldValue.delete(),
          'promotionEndDate': FieldValue.delete(),
        }),
      ]);

      _updateLocalDiscounts(discountId, productId);
    } catch (e) {
      Get.snackbar('Lỗi', 'Xóa sản phẩm khỏi khuyến mãi thất bại: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteDiscountCode(String id) async {
    try {
      await _promotionService.removeDiscountCode(id);
      discountCodes.value = discountCodes.value.where((e) => e.id != id).toList();
    } catch (e) {
      Get.snackbar('Lỗi', 'Xóa mã giảm giá thất bại: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateDiscountCode(DiscountCodeModel code) async {
    try {
      await _promotionService.updateDiscountCode(code);

      int index = discountCodes.value.indexWhere((c) => c.id == code.id);
      if (index != -1) {
        discountCodes.value[index] = code;
        discountCodes.refresh();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProductDiscount(ProductPromotionModel product) async {
    try {
      await _promotionService.updateProductDiscount(product);
      int index = productDiscounts.value.indexWhere((c) => c.id == product.id);
      if (index != -1) {
        productDiscounts.value[index] = product;
        productDiscounts.refresh();
      }
    } catch (e) {
      rethrow;
    }
  }

  void _updateLocalDiscounts(String discountId, String productId) {
    final updatedDiscounts =
        productDiscounts.value.map((discount) {
          if (discount.id == discountId) {
            return discount.copyWith(productIds: discount.productIds.where((id) => id != productId).toList());
          }
          return discount;
        }).toList();
    productDiscounts.value = updatedDiscounts;

    final updatedProducts =
        allProducts.value.map((product) {
          if (product.id == productId) {
            return product.copyWith(promotion: null, promotionPrice: null, promotionEndDate: null);
          }
          return product;
        }).toList();

    allProducts.value = updatedProducts;
  }

  // ========== Helper Methods ========== //
  void _validateProductForDiscount(ProductModel product, String discountId) {
    if (product.promotion != null) {
      if (product.promotion == discountId) {
        throw Exception('Sản phẩm đã thuộc khuyến mãi này');
      } else {
        throw Exception('Sản phẩm đã thuộc khuyến mãi khác (ID: ${product.promotion})');
      }
    }
  }

  Future<void> _applyDiscountToProduct(
    String discountId,
    String productId,
    double discountedPrice,
    DateTime? endDate,
  ) async {
    final batch = FirebaseFirestore.instance.batch();

    final promotionRef = FirebaseFirestore.instance.collection('product_discounts').doc(discountId);
    batch.update(promotionRef, {
      'productIds': FieldValue.arrayUnion([productId]),
    });

    final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    batch.update(productRef, {'promotion': discountId, 'promotionPrice': discountedPrice, 'promotionEndDate': endDate});

    await batch.commit();
    _syncLocalData(discountId, productId, discountedPrice);
  }

  void _syncLocalData(String discountId, String productId, double discountedPrice) {
    // Cập nhật danh sách khuyến mãi
    final updatedDiscounts =
        productDiscounts.value.map((discount) {
          if (discount.id == discountId) {
            return discount.copyWith(productIds: [...discount.productIds, productId]);
          }
          return discount;
        }).toList();
    productDiscounts.value = updatedDiscounts;

    // Cập nhật danh sách sản phẩm
    final updatedProducts =
        allProducts.value.map((product) {
          if (product.id == productId) {
            return product.copyWith(promotion: discountId, promotionPrice: discountedPrice);
          }
          return product;
        }).toList();
    allProducts.value = updatedProducts;
  }

  Future<void> _removeDiscountFromProducts(List<String> productIds) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final productId in productIds) {
      final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
      batch.update(productRef, {
        'promotion': FieldValue.delete(),
        'promotionPrice': FieldValue.delete(),
        'promotionEndDate': FieldValue.delete(),
      });
    }
    await batch.commit();
  }

  void _syncProductsWithDiscounts() {
    allProducts.value =
        allProducts.value.map((product) {
          if (product.promotion != null) {
            final discount = productDiscounts.value.firstWhereOrNull((d) => d.id == product.promotion);

            if (discount == null) {
              return product.copyWith(promotion: null, promotionPrice: null);
            }
          }
          return product;
        }).toList();
  }

  double _calculateDiscountedPrice({
    required double price,
    required double discountValue,
    required String discountType,
  }) {
    final discountedPrice = discountType == 'percent' ? price * (1 - discountValue / 100) : price - discountValue;

    return discountedPrice > 0 ? discountedPrice : 0;
  }

  List<ProductModel> getProductsByIds(List<String> ids, String storeId) {
    return allProducts.value.where((p) => ids.contains(p.id) && p.storeId == storeId).toList();
  }

  List<ProductModel> getAvailableProductsForDiscount(String discountId, String storeId) {
    return allProducts.value
        .where((p) => (p.promotion == null || p.promotion != discountId) && p.storeId == storeId)
        .toList();
  }
}
