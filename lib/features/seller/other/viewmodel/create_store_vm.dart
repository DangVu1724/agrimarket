import 'package:agrimarket/data/repo/store_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/location_service.dart';
import 'package:agrimarket/data/services/image_service.dart';
import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import 'package:image_picker/image_picker.dart';

class CreateStoreViewModel extends GetxController {
  final LocationService _locationService = LocationService();
  final ImageService _imageService = ImageService();
  final StoreRepository _storeRepository = StoreRepository();
  final formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final provinceController = TextEditingController();
  final districtController = TextEditingController();
  final wardController = TextEditingController();
  final streetController = TextEditingController();
  final houseNumberController = TextEditingController();

  // Danh sách dữ liệu
  final provinces = <Map<String, dynamic>>[].obs;
  final districts = <Map<String, dynamic>>[].obs;
  final wards = <Map<String, dynamic>>[].obs;
  final categories = <String>[].obs;
  final availableCategories =
      [
        'Trái cây',
        'Rau củ',
        'Thực phẩm chế biến',
        'Ngũ cốc - Hạt',
        'Sữa & Trứng',
        'Thịt',
        'Thuỷ hải sản',
        'Gạo',
      ].obs;

  // Trạng thái
  final isLoading = RxBool(false);
  final isLoadingDistrict = RxBool(false);
  final isLoadingProvince = RxBool(false);
  final isLoadingWard = RxBool(false);
  final selectedProvinceCode = RxnString();
  final selectedDistrictCode = RxnString();
  final selectedWardCode = RxnString();
  final businessLicenseFile = Rxn<XFile>();
  final foodSafetyCertificateFile = Rxn<XFile>();

  @override
  void onInit() {
    super.onInit();
    _locationService.fetchProvinces(provinces);
    provinceController.addListener(onProvinceChanged);
    districtController.addListener(onDistrictChanged);
  }

  void onProvinceChanged() {
    final selected = provinces.firstWhereOrNull(
      (p) => p['name'] == provinceController.text,
    );
    if (selected != null && selected['code'] != null) {
      selectedProvinceCode.value = selected['code'].toString();
      districts.clear();
      wards.clear();
      districtController.clear();
      wardController.clear();
      selectedDistrictCode.value = null;
      selectedWardCode.value = null;
      isLoadingProvince.value = true;
      
      _locationService.fetchDistricts(selectedProvinceCode.value!, districts);
    } else {
      _clearLocationData();
    }
    update();
  }

  void onDistrictChanged() async {
    final input = districtController.text.trim();

    if (districts.isEmpty && !isLoadingDistrict.value) {
      selectedDistrictCode.value = null;
      selectedWardCode.value = null;
      wards.clear();
      wardController.clear();
      update();
      return;
    }

    // Tìm quận/huyện khớp với input
    final selected = districts.firstWhereOrNull(
      (d) => (d['name'] as String?)?.trim().toLowerCase() == input.toLowerCase(),
    );

    if (selected != null && selected['code'] != null) {
      selectedDistrictCode.value = selected['code'].toString();
      wards.clear();
      wardController.clear();
      selectedWardCode.value = null;
      isLoadingWard.value = true; 

      try {
        await _locationService.fetchWards(selectedDistrictCode.value!, wards);
        if (wards.isEmpty) {
          Get.snackbar('Thông báo', 'Không có phường/xã nào cho quận/huyện này.');
        }
      } catch (e) {
        Get.snackbar('Lỗi', 'Không thể tải danh sách phường/xã: $e');
        wards.clear();
        wardController.clear();
        selectedWardCode.value = null;
      } finally {
        isLoadingWard.value = false; // Kết thúc tải phường/xã
      }
    } else {
      selectedDistrictCode.value = null;
      selectedWardCode.value = null;
      wards.clear();
      wardController.clear();
      Get.snackbar(
        'Lỗi',
        input.isEmpty
            ? 'Vui lòng nhập hoặc chọn quận/huyện.'
            : 'Quận/huyện "$input" không hợp lệ. Vui lòng chọn từ danh sách.',
        snackPosition: SnackPosition.TOP,
      );
    }
    update();
  }

  void onWardChanged() {
    final input = wardController.text.trim();
    final selected = wards.firstWhereOrNull(
      (w) => (w['name'] as String?)?.trim().toLowerCase() == input.toLowerCase(),
    );

    if (selected != null && selected['code'] != null) {
      selectedWardCode.value = selected['code'].toString();
    } else {
      selectedWardCode.value = null;
      Get.snackbar(
        'Lỗi',
        input.isEmpty
            ? 'Vui lòng nhập hoặc chọn phường/xã.'
            : 'Phường/xã "$input" không hợp lệ. Vui lòng chọn từ danh sách.',
        snackPosition: SnackPosition.TOP,
      );
    }
    update();
  }

  void toggleCategory(String category) {
    categories.contains(category)
        ? categories.remove(category)
        : categories.add(category);
  }

  Future<void> pickImage({
    required bool isBusinessLicense,
    bool fromCamera = false,
  }) async {
    final file = await _imageService.pickImage(fromCamera: fromCamera);
    if (file != null) {
      isBusinessLicense
          ? businessLicenseFile.value = file
          : foodSafetyCertificateFile.value = file;
    }
  }

  void clearImage(bool isBusinessLicense) {
    isBusinessLicense
        ? businessLicenseFile.value = null
        : foodSafetyCertificateFile.value = null;
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
        'certificates'
      );
      final foodSafetyCertificateUrl = await _imageService.uploadImageToGitHub(
        foodSafetyCertificateFile.value,
        storeId,
        'food_safety',
        'certificates'
      );

      if (businessLicenseUrl == null || foodSafetyCertificateUrl == null) {
        throw Exception('Không thể tải lên giấy tờ');
      }

      final store = StoreModel(
        storeId: storeId,
        ownerUid: user.uid,
        name: nameController.text,
        description: descriptionController.text,
        categories: categories.toList(),
        address:
            '${houseNumberController.text}, ${streetController.text}, ${wardController.text}, ${districtController.text}, ${provinceController.text}',
        businessLicenseUrl: businessLicenseUrl,
        foodSafetyCertificateUrl: foodSafetyCertificateUrl,
        state: 'pending',
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
        provinceController.text.isEmpty ||
        districtController.text.isEmpty ||
        wardController.text.isEmpty ||
        streetController.text.isEmpty ||
        houseNumberController.text.isEmpty ||
        selectedProvinceCode.value == null ||
        selectedDistrictCode.value == null ||
        selectedWardCode.value == null ||
        businessLicenseFile.value == null ||
        foodSafetyCertificateFile.value == null) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin');
      return false;
    }
    return true;
  }

  void _clearLocationData() {
    selectedProvinceCode.value = null;
    selectedDistrictCode.value = null;
    selectedWardCode.value = null;
    districts.clear();
    wards.clear();
    districtController.clear();
    wardController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    provinceController.dispose();
    districtController.dispose();
    wardController.dispose();
    streetController.dispose();
    houseNumberController.dispose();
    super.onClose();
  }
}
