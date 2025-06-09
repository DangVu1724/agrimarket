import 'dart:ui';

import 'package:agrimarket/data/providers/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerHomeVm extends GetxController{
  final FirestoreProvider firestoreProvider = FirestoreProvider();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final storeName = RxString('');
  final storeState = RxString('');
  final isLoading = RxBool(false);
  final hasError = RxBool(false);
  final errorMessage = RxString('');
  final storeStateColor = Rx<Color>(Colors.grey);



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
        final store = stores.first; 
        storeName.value = store.name;
        updateStoreState(store.state);
        storeState.value = store.state;
        print('Cửa hàng: ${store.name}, Trạng thái: ${store.state}');
        // if (storeState.value == 'pending') {
        //   Get.snackbar('Thông báo', 'Cửa hàng đang chờ kiểm duyệt.');
        // }
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

  void updateStoreState(String state) {
    storeState.value = state;
    storeStateColor.value = getStateColor(state);
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
 

}