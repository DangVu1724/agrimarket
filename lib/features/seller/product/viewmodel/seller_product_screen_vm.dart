import 'package:agrimarket/data/repo/product_repo.dart';
import 'package:agrimarket/data/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/image_service.dart';
import 'package:agrimarket/data/services/seller_store_service.dart';
import 'package:image_picker/image_picker.dart';

class SellerProductVm extends GetxController {
  final SellerStoreService _sellerStoreService = SellerStoreService();
  final ProductRepository _productRepository = ProductRepository();
  final ImageService _imageService = ImageService();
  final ProductService _filterService = ProductService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final GlobalKey<FormState> productKey = GlobalKey<FormState>();

  StoreModel? storeModel;
  final RxnString categoryDefault = RxnString();
  final RxList<String> categories = <String>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentImageUrl = ''.obs;
  final Rxn<XFile> imageProduct = Rxn<XFile>();

  @override
  void onInit() {
    super.onInit();
    _loadStoreData();
    searchController.addListener(() => searchQuery.value = searchController.text.trim());
  }

  Future<void> _loadStoreData() async {
    try {
      storeModel = await _sellerStoreService.getCurrentSellerStore();
      if (storeModel != null) {
        categories.assignAll(storeModel!.categories);
        categoryDefault.value = categories.isNotEmpty ? categories.first : null;
        await fetchProducts();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải dữ liệu cửa hàng: $e');
    }
  }

  Future<void> fetchProducts() async {
    if (storeModel == null) return;
    try {
      isLoading.value = true;
      final products = await _productRepository.fetchProductsByStoreId(storeModel!.storeId);
      allProducts.assignAll(products);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải sản phẩm: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void initUpdateProduct(ProductModel product) {
    nameController.text = product.name;
    descController.text = product.description;
    priceController.text = product.price.toString();
    quantityController.text = product.quantity.toString();
    unitController.text = product.unit;
    categoryDefault.value = product.category;
    currentImageUrl.value = product.imageUrl;
  }

  List<ProductModel> getFilteredProducts() {
    return _filterService.filterProducts(
      allProducts,
      storeModel?.storeId ?? '',
      selectedCategory.value,
      searchQuery.value,
    );
  }

  Future<void> submitProduct() async {
    if (!_validateForm()) return;
    try {
      final imageUrl = await _uploadImage();
      if (imageUrl == null) {
        Get.snackbar('Lỗi', 'Tải ảnh lên thất bại');
        return;
      }

      final product = _createProductModel(imageUrl);
      final docRef = await _productRepository.createProduct(product);
      allProducts.add(ProductModel.fromJson({...product.toJson(), 'id': docRef.id}));
      Get.snackbar('Thành công', 'Sản phẩm đã được thêm');
      resetForm();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm sản phẩm: $e');
    }
  }

  Future<void> updateProduct(String productId) async {
    if (!_validateForm()) return;
    try {
      String? imageUrl;
      if (imageProduct.value != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null) {
          Get.snackbar('Lỗi', 'Tải ảnh lên thất bại');
          return;
        }
      } else {
        imageUrl = currentImageUrl.value;
      }

      final existingProduct = allProducts.firstWhere((p) => p.id == productId);
      final product = _createProductModel(imageUrl.isNotEmpty ? imageUrl : existingProduct.imageUrl);
      await _productRepository.updateProduct(productId, product);
      final index = allProducts.indexWhere((p) => p.id == productId);
      if (index != -1) {
        allProducts[index] = ProductModel.fromJson({...product.toJson(), 'id': productId});
      }
      Get.snackbar('Thành công', 'Sản phẩm đã được cập nhật');
      resetForm();
      Get.back();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật sản phẩm: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productRepository.deleteProduct(productId);
      allProducts.removeWhere((product) => product.id == productId);
      Get.snackbar('Thành công', 'Đã xóa sản phẩm');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa sản phẩm: $e');
    }
  }

  void resetForm() {
    nameController.clear();
    descController.clear();
    priceController.clear();
    unitController.clear();
    quantityController.clear();
    imageProduct.value = null;
    categoryDefault.value = categories.isNotEmpty ? categories.first : null;
  }

  void clearFilters() {
    searchController.clear();
    selectedCategory.value = '';
  }

  bool _validateForm() {
    if (storeModel == null) {
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin cửa hàng.');
      return false;
    }
    if (!productKey.currentState!.validate()) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin.');
      return false;
    }
    // Kiểm tra giá và số lượng không được âm
    final price = double.tryParse(priceController.text.trim()) ?? 0.0;
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    if (price <= 0) {
      Get.snackbar('Lỗi', 'Giá sản phẩm không được nhỏ hơn 0.');
      return false;
    }
    if (quantity <= 0) {
      Get.snackbar('Lỗi', 'Số lượng sản phẩm không được nhỏ hơn 0.');
      return false;
    }
    return true;
  }

  ProductModel _createProductModel(String imageUrl) {
    final tags1 = nameController.text.split(',').map((e) => e.trim()).toList();
    final tags2 = categoryDefault.value?.split(',').map((e) => e.trim()).toList() ?? [];
    final tags = [...tags1, ...tags2];
    return ProductModel(
      id: '',
      name: nameController.text.trim(),
      description: descController.text.trim(),
      price: double.tryParse(priceController.text.trim()) ?? 0.0,
      unit: unitController.text.trim(),
      quantity: int.tryParse(quantityController.text.trim()) ?? 0,
      category: categoryDefault.value ?? '',
      storeId: storeModel!.storeId,
      imageUrl: imageUrl,
      tags: tags,
    );
  }

  Future<void> pickProductImage({bool fromCamera = false}) async {
    final picked = await _imageService.pickImage(fromCamera: fromCamera);
    if (picked != null) {
      imageProduct.value = picked;
    } else {
      Get.snackbar('Thông báo', 'Không có ảnh nào được chọn.');
    }
  }

  Future<String?> _uploadImage() async {
    if (imageProduct.value == null) return null;
    return await _imageService.uploadImageToGitHub(
      imageProduct.value,
      storeModel!.storeId,
      nameController.text,
      'imageProducts',
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    unitController.dispose();
    quantityController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
