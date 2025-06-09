import 'dart:convert';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class SellerProductVm extends GetxController {
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

  final name = RxString('');
  final des = RxString('');
  final price = RxString('');
  final quantity = RxString('');

  final Rxn<XFile> imageProduct = Rxn<XFile>();
  final ImagePicker _picker = ImagePicker();
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStoreData();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
    });
  }

  Future<void> fetchStoreData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Lỗi', 'Không tìm thấy người dùng. Vui lòng đăng nhập lại.');
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .where('ownerUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.snackbar('Lỗi', 'Không tìm thấy cửa hàng cho người dùng này.');
        return;
      }

      final doc = querySnapshot.docs.first;
      storeModel = StoreModel.fromJson(doc.data());

      categories.assignAll(storeModel!.categories);
      categoryDefault.value = categories.isNotEmpty ? categories.first : null;

      if (storeModel != null) {
        await fetchProductsByStoreId(storeModel!.storeId);
      }

      update();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải dữ liệu cửa hàng: $e');
    }
  }

  Future<void> fetchProductsByStoreId(String storeId) async {
    try {
      isLoading.value = true;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('storeId', isEqualTo: storeId)
          .get();

      allProducts.clear();
      allProducts.addAll(querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProductModel.fromJson(data);
      }).toList());
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải sản phẩm: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Hàm lọc sản phẩm dựa trên danh mục và từ khóa tìm kiếm
  List<ProductModel> getFilteredProducts(String storeId) {
    var filteredProducts = allProducts.where((product) => product.storeId == storeId).toList();

    if (selectedCategory.value.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) => product.category == selectedCategory.value)
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) =>
              product.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    return filteredProducts;
  }

  void addProduct(ProductModel product) {
    allProducts.add(product);
  }

  Future<void> pickImage({bool fromCamera = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        imageProduct.value = image;
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn ảnh: $e');
    }
  }

  void clearImage() {
    imageProduct.value = null;
  }

  Future<String?> _uploadImageToGitHub(XFile? file, String storeId, String name) async {
    if (file == null) return null;
    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final fileName = '$name.jpg';
      final path = '$storeId/imageProduct/$fileName';

      if (!dotenv.isInitialized) {
        throw Exception('dotenv not initialized. Check .env file and main.dart');
      }

      final token = dotenv.env['GITHUB_TOKEN'];
      final owner = dotenv.env['GITHUB_OWNER'];
      final repo = dotenv.env['GITHUB_REPO'];

      if (token == null || owner == null || repo == null) {
        throw Exception('GitHub configuration missing: token=$token, owner=$owner, repo=$repo');
      }

      final getUri = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');
      String? sha;
      final getResponse = await http.get(
        getUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );
      if (getResponse.statusCode == 200) {
        final getData = jsonDecode(getResponse.body);
        sha = getData['sha'];
      }

      final uri = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');
      final body = {
        'message': 'Upload for store $storeId',
        'content': base64Image,
      };
      if (sha != null) {
        body['sha'] = sha;
      }

      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final downloadUrl = data['content']['download_url'] as String?;
        if (downloadUrl == null) {
          throw Exception('Download URL not found in response');
        }
        return downloadUrl;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('GitHub API error: ${errorData['message']} (Status: ${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải ảnh lên GitHub: $e');
      return null;
    }
  }

  void submitProduct() async {
    if (!productKey.currentState!.validate()) return;
    if (storeModel == null) {
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin cửa hàng.');
      return;
    }

    final storeId = storeModel!.storeId;
    final imageUrl = await _uploadImageToGitHub(
      imageProduct.value,
      storeId,
      nameController.text,
    );

    if (imageUrl == null) {
      Get.snackbar('Lỗi', 'Tải ảnh lên thất bại');
      return;
    }

    final productData = {
      'name': nameController.text.trim(),
      'description': descController.text.trim(),
      'price': double.tryParse(priceController.text.trim()) ?? 0.0,
      'unit': unitController.text.trim(),
      'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
      'category': categoryDefault.value,
      'storeId': storeId,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef = await FirebaseFirestore.instance.collection('products').add(productData);
    final product = ProductModel.fromJson({
      ...productData,
      'id': docRef.id,
    });
    addProduct(product);
    Get.snackbar('Thành công', 'Sản phẩm đã được thêm');
    resetForm();
  }

  Future<void> updateProduct(String productId) async {
    if (!productKey.currentState!.validate()) return;
    if (storeModel == null) {
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin cửa hàng.');
      return;
    }

    try {
      final storeId = storeModel!.storeId;
      String? imageUrl;
      if (imageProduct.value != null) {
        imageUrl = await _uploadImageToGitHub(
          imageProduct.value,
          storeId,
          nameController.text,
        );
      }

      if (imageUrl == null && imageProduct.value != null) {
        Get.snackbar('Lỗi', 'Tải ảnh lên thất bại');
        return;
      }

      final productData = {
        'name': nameController.text.trim(),
        'description': descController.text.trim(),
        'price': double.tryParse(priceController.text.trim()) ?? 0.0,
        'unit': unitController.text.trim(),
        'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
        'category': categoryDefault.value,
        'storeId': storeId,
        'imageUrl': imageUrl ?? allProducts.firstWhere((p) => p.id == productId).imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('products').doc(productId).update(productData);
      final index = allProducts.indexWhere((p) => p.id == productId);
      if (index != -1) {
        allProducts[index] = ProductModel.fromJson({
          ...productData,
          'id': productId,
        });
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
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
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

  // Xóa bộ lọc
  void clearFilters() {
    searchController.clear();
    selectedCategory.value = '';
  }
}