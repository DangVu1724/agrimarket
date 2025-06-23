import 'dart:ui';

import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/providers/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerHomeVm extends GetxController {
  final FirestoreProvider firestoreProvider = FirestoreProvider();
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
    fetchStoreInfo();
  }

  Future<void> fetchStoreInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      hasError.value = true;
      errorMessage.value = 'Người dùng chưa đăng nhập';
      Get.snackbar('Lỗi', errorMessage.value);
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Lấy cửa hàng từ Firestore dựa trên ownerUid
      final stores = await firestoreProvider.getStoresByOwner(user.uid);
      if (stores.isNotEmpty) {
        final s = stores.first;
        store.value = s;
        isOpened.value = s.isOpened;
        storeStateColor.value = getStateColor(s.state);

      } else {
        hasError.value = true;
        errorMessage.value = 'Không tìm thấy cửa hàng nào cho người dùng này.';
        Get.snackbar('Lỗi', errorMessage.value);
      }
    } catch (e) {
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
      case 'ban':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

   Future<void> toggleOpen() async {
    if (store.value == null) return;

    final newStatus = !store.value!.isOpened;
  try {
    await firestore.collection('stores').doc(store.value!.storeId).update({
      'isOpened': newStatus,
    });

    store.value = store.value!.copyWith(isOpened: newStatus);
    store.refresh();
    isOpened.value = newStatus;

  } catch (e) {
    Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái cửa hàng: $e');
  }
}
}