import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/data/models/buyer.dart';
import 'package:agrimarket/data/providers/firestore_provider.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class AddressViewModel extends GetxController {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  final FirestoreProvider _firestoreProvider = FirestoreProvider();
  final Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  final isLoading = false.obs;
  final mapController = MapController();

  void selectLocation(LatLng latLng) async {
    selectedLocation.value = latLng;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        addressController.text =
            "${placemark.street ?? ''}, ${placemark.subAdministrativeArea ?? ''}, ${placemark.administrativeArea ?? ''} ,${placemark.country ?? ''}"
                .trim();
        print("Placemark received: $placemark");
      }
      mapController.move(latLng, 15.0); // Di chuyển bản đồ đến vị trí đã chọn
    } catch (e) {
      print("Lỗi khi lấy địa chỉ từ tọa độ: $e");
    }
  }

  void searchAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);
        selectedLocation.value = latLng;
        mapController.move(latLng, 15);
      }
    } catch (e) {
      print("Lỗi khi tìm tọa độ từ địa chỉ: $e");
    }
  }

  Future<void> saveAddress() async {
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

    try {
      // Lấy BuyerModel hiện tại
      BuyerModel? buyer = await _firestoreProvider.getBuyerById(uid);
      buyer ??= BuyerModel(
          uid: uid,
          favoriteStoreIds: [],
          addresses: [],
          reviews: [],
          orderIds: [],
        );

      // Thêm địa chỉ mới vào danh sách addresses
      final newAddress = Address(
        label: label,
        address: address,
        latitude: location.latitude,
        longitude: location.longitude,
        isDefault: buyer.addresses.isEmpty,
      );
      final updatedAddresses = [...buyer.addresses, newAddress];

      // Cập nhật BuyerModel
      final updatedBuyer = BuyerModel(
        uid: buyer.uid,
        favoriteStoreIds: buyer.favoriteStoreIds,
        addresses: updatedAddresses,
        reviews: buyer.reviews,
        orderIds: buyer.orderIds,
      );

      // Lưu BuyerModel vào Firestore
      await _firestoreProvider.createBuyer(updatedBuyer);

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

    try {
      BuyerModel? buyer = await _firestoreProvider.getBuyerById(uid);
      if (buyer == null) return;

      final updatedAddress = Address(
        label: label,
        address: address,
        latitude: location.latitude,
        longitude: location.longitude,
      );

      final updatedAddresses = List<Address>.from(buyer.addresses);
      updatedAddresses[indexToUpdate] = updatedAddress;

      final updatedBuyer = BuyerModel(
        uid: buyer.uid,
        favoriteStoreIds: buyer.favoriteStoreIds,
        addresses: updatedAddresses,
        reviews: buyer.reviews,
        orderIds: buyer.orderIds,
      );

      await _firestoreProvider.createBuyer(updatedBuyer);

      Get.offAllNamed(AppRoutes.buyerHome);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật địa chỉ: $e');
    }
  }

  Future<void> setDefaultAddress(int index) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    BuyerModel? buyer = await _firestoreProvider.getBuyerById(uid);
    if (buyer == null) return;

    List<Address> updatedAddresses =
        buyer.addresses.asMap().entries.map((entry) {
          int i = entry.key;
          Address address = entry.value;
          return Address(
            label: address.label,
            address: address.address,
            latitude: address.latitude,
            longitude: address.longitude,
            isDefault: i == index,
          );
        }).toList();

    final updatedBuyer = BuyerModel(
      uid: buyer.uid,
      favoriteStoreIds: buyer.favoriteStoreIds,
      addresses: updatedAddresses,
      reviews: buyer.reviews,
      orderIds: buyer.orderIds,
    );

    await _firestoreProvider.createBuyer(updatedBuyer);
    Get.find<BuyerVm>().fetchBuyerData();
    Get.snackbar('Thành công', 'Đã đặt địa chỉ mặc định');
  }


  @override
  void onClose() {
    addressController.dispose();
    labelController.dispose();
    super.onClose();
  }
}
