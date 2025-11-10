import 'dart:ui';

import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/seller_store_service.dart';
import 'package:agrimarket/data/services/store_promotion_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerHomeVm extends GetxController {
  final SellerStoreService _sellerStoreService = SellerStoreService();
  final StorePromotionService _storePromotionService = StorePromotionService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final Rx<StoreModel?> store = Rx<StoreModel?>(null);
  final isLoading = RxBool(false);
  final hasError = RxBool(false);
  final errorMessage = RxString('');
  final storeStateColor = Rx<Color>(Colors.grey);
  var isOpened = true.obs;

  @override
  void onInit() {
    super.onInit();
    clearStoreData();
    fetchStoreInfo();
  }

  @override
  void onClose() {
    _storePromotionService.dispose();
    super.onClose();
  }

  void clearStoreData() {
    print('🧹 Clearing seller store data...');
    store.value = null;
    isLoading.value = false;
    hasError.value = false;
    errorMessage.value = '';
    storeStateColor.value = Colors.grey;
    isOpened.value = true;
  }

  Future<void> migrateAddressToObject() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('stores').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('address')) {
        final oldAddress = data['address'];

        final addressObj = StoreAddress(
          label: 'Cửa hàng chính',
          address: oldAddress,
          latitude: 21.0285,
          longitude: 105.8542,
        );

        await doc.reference.update({
          'storeLocation': addressObj.toJson(), // đổi key thành storeLocation
          'address': FieldValue.delete(), // xóa trường cũ nếu cần
        });

        print('Migrated store ${doc.id}');
      } else {
        print('Store ${doc.id} has no address field');
      }
    }

    print('✅ Migration complete.');
  }

  Future<void> fetchStoreInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      hasError.value = true;
      errorMessage.value = 'Người dùng chưa đăng nhập';
      Get.snackbar('Lỗi', errorMessage.value);
      return;
    }

    print('🔍 Fetching store info for user: ${user.uid}');
    print('🔍 User email: ${user.email}');

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Lấy cửa hàng từ SellerStoreService
      final sellerStore = await _sellerStoreService.getCurrentSellerStore();

      if (sellerStore != null) {
        print('✅ Selected store: ${sellerStore.storeId} - ${sellerStore.name}');
        store.value = sellerStore;
        isOpened.value = sellerStore.isOpened;
        storeStateColor.value = getStateColor(sellerStore.state);

        // Bắt đầu lắng nghe thay đổi khuyến mãi cho store này
        _storePromotionService.listenToPromotionChanges(sellerStore.storeId);

        // Cập nhật trạng thái khuyến mãi ban đầu
        await _storePromotionService.updateStorePromotionStatus(sellerStore.storeId);
      } else {
        print('❌ No stores found for user: ${user.uid}');
        hasError.value = true;
        errorMessage.value = 'Không tìm thấy cửa hàng nào cho người dùng này.';
        Get.snackbar('Lỗi', errorMessage.value);
      }
    } catch (e) {
      print('❌ Error fetching store info: $e');
      hasError.value = true;
      errorMessage.value = 'Lỗi khi lấy thông tin cửa hàng: $e';

      Get.snackbar('Lỗi', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Color getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'verify':
        return Colors.green;
      case 'locked':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> toggleOpen() async {
    if (store.value == null) return;

    final newStatus = !store.value!.isOpened;
    try {
      await firestore.collection('stores').doc(store.value!.storeId).update({'isOpened': newStatus});

      store.value = store.value!.copyWith(isOpened: newStatus);
      store.refresh();
      isOpened.value = newStatus;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái cửa hàng: $e');
    }
  }

  // Method to refresh store data (useful when switching users)
  Future<void> refreshStoreData() async {
    print('🔄 Refreshing seller store data...');
    clearStoreData();
    await fetchStoreInfo();
  }

  // Simple refresh method for error recovery
  Future<void> refresh() async {
    print('🔄 Simple refresh...');
    try {
      await fetchStoreInfo();
    } catch (e) {
      print('❌ Error in refresh: $e');
    }
  }
}
