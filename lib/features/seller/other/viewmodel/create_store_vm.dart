import 'package:agrimarket/data/repo/store_repo.dart';
import 'package:agrimarket/data/services/address_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/image_service.dart';
import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class CreateStoreViewModel extends GetxController {
  final ImageService _imageService = ImageService();
  final StoreRepository _storeRepository = StoreRepository();
  final formKey = GlobalKey<FormState>();
  final StoreRepository _storeRepo = StoreRepository();

  // Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  final mapController = MapController();

  // Danh sách dữ liệu
  final categories = <String>[].obs;
  final availableCategories =
      ['Trái cây', 'Rau củ', 'Thực phẩm chế biến', 'Ngũ cốc - Hạt', 'Sữa & Trứng', 'Thịt', 'Thuỷ hải sản', 'Gạo'].obs;

  // Trạng thái
  final isLoading = RxBool(false);
  final businessLicenseFile = Rxn<XFile>();
  final foodSafetyCertificateFile = Rxn<XFile>();
  final storeImageFile = Rxn<XFile>();


  final Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);

  void selectLocation(LatLng latLng) async {
    selectedLocation.value = latLng;
    try {
      addressController.text = await AddressService.getAddressFromLatLng(latLng);
      mapController.move(latLng, 15.0);
    } catch (e) {
      print("Lỗi khi lấy địa chỉ: $e");
    }
  }

  void searchAddress(String address) async {
    try {
      final latLng = await AddressService.getLatLngFromAddress(address);
      if (latLng != null) {
        selectedLocation.value = latLng;
        mapController.move(latLng, 15);
      }
    } catch (e) {
      print("Lỗi khi tìm tọa độ từ địa chỉ: $e");
    }
  }

  void toggleCategory(String category) {
    categories.contains(category) ? categories.remove(category) : categories.add(category);
  }

  StoreAddress toStoreAddress() {
    final LatLng loc = selectedLocation.value!;
    return StoreAddress(
      label: labelController.text.trim(),
      address: addressController.text.trim(),
      latitude: loc.latitude,
      longitude: loc.longitude,
    );
  }

  Future<void> updateStoreLocation(StoreModel newStore) async {
    await _storeRepo.updateStore(newStore);
  }

  Future<void> pickImage({required String imageType, bool fromCamera = false}) async {
    final file = await _imageService.pickImage(fromCamera: fromCamera);
    if (file != null) {
      if (imageType == 'license') {
        businessLicenseFile.value = file;
      } else if (imageType == 'food') {
        foodSafetyCertificateFile.value = file;
      } else if (imageType == 'store') {
        storeImageFile.value = file;
      }
    }
  }

  void clearImage(String imageType) {
    if (imageType == 'license') {
      businessLicenseFile.value = null;
    } else if (imageType == 'food') {
      foodSafetyCertificateFile.value = null;
    } else if (imageType == 'store') {
      storeImageFile.value = null;
    }
  }

  Future<void> saveStore() async {
    if (!_validateForm()) return;
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Lỗi', 'Người dùng chưa đăng nhập');
        return;
      }
      final storeId = 'store_${user.uid}_${Random().nextInt(10000)}';
      final businessLicenseUrl = await _imageService.uploadImageToGitHub(
        businessLicenseFile.value,
        storeId,
        'business_license',
        'certificates',
      );
      final foodSafetyCertificateUrl = await _imageService.uploadImageToGitHub(
        foodSafetyCertificateFile.value,
        storeId,
        'food_safety',
        'certificates',
      );

      final storeImageUrl = await _imageService.uploadImageToGitHub(
        storeImageFile.value,
        storeId,
        'store_image',
        'logo',
      );

      if (businessLicenseUrl == null || foodSafetyCertificateUrl == null || storeImageUrl == null) {
        throw Exception('Không thể tải lên giấy tờ');
      }

      final store = StoreModel(
        storeId: storeId,
        ownerUid: user.uid,
        name: nameController.text,
        description: descriptionController.text,
        categories: categories.toList(),
        storeLocation: StoreAddress(
          label: labelController.text.trim(),
          address: addressController.text.trim(),
          latitude: selectedLocation.value!.latitude,
          longitude: selectedLocation.value!.longitude,
        ),

        businessLicenseUrl: businessLicenseUrl,
        foodSafetyCertificateUrl: foodSafetyCertificateUrl,
        storeImageUrl: storeImageUrl,
        state: 'pending',
        isOpened: false,
      );

      await _storeRepository.createStore(store);
      Get.offAllNamed(AppRoutes.sellerHome);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tạo cửa hàng: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        categories.isEmpty ||
        businessLicenseFile.value == null ||
        foodSafetyCertificateFile.value == null ||
        storeImageFile.value == null ||
        addressController.text.isEmpty ||
        labelController.text.isEmpty ||
        selectedLocation.value == null) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin');
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
