import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/data/models/buyer.dart';
import 'package:agrimarket/data/repo/address_repo.dart';
import 'package:agrimarket/data/services/address_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class AddressViewModel extends GetxController {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  final Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  final isLoading = false.obs;
  final mapController = MapController();
  final AddressRepository _addressRepo = AddressRepository();
  
  void selectLocation(LatLng latLng) async {
    selectedLocation.value = latLng;
    try {
      addressController.text = await AddressService.getAddressFromLatLng(
        latLng,
      );
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

  Future<void> saveAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null ||
        selectedLocation.value == null ||
        labelController.text.isEmpty ||
        addressController.text.isEmpty) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng nhập đủ dữ liệu và đăng nhập');
      return;
    }

    final newAddress = Address(
      label: labelController.text,
      address: addressController.text,
      latitude: selectedLocation.value!.latitude,
      longitude: selectedLocation.value!.longitude,
      isDefault: false,
    );

    try {
      await _addressRepo.addAddress(uid, newAddress);
      Get.offAllNamed(AppRoutes.buyerHome);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể lưu địa chỉ: $e');
    }
  }

  Future<void> updateAddress(int indexToUpdate) async {
    final location = selectedLocation.value;
    final address = addressController.text;
    final label = labelController.text;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (location == null || address.isEmpty || label.isEmpty || uid == null) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng nhập nhãn, địa chỉ, chọn vị trí và đảm bảo đã đăng nhập',
      );
      return;
    }

    final updatedAddress = Address(
      label: label,
      address: address,
      latitude: location.latitude,
      longitude: location.longitude,
    );

    try {
      await _addressRepo.updateAddress(uid, indexToUpdate, updatedAddress);
      Get.offAllNamed(AppRoutes.buyerHome);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật địa chỉ: $e');
    }
  }

  Future<void> setDefaultAddress(int index) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await _addressRepo.setDefaultAddress(uid, index);
      Get.find<BuyerVm>().fetchBuyerData();
      Get.snackbar('Thành công', 'Đã đặt địa chỉ mặc định');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể đặt địa chỉ mặc định: $e');
    }
  }

  @override
  void onClose() {
    addressController.dispose();
    labelController.dispose();
    super.onClose();
  }
}
