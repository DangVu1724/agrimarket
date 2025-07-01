import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/repo/store_repo.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreInfoVm extends GetxController {
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController storeDesController = TextEditingController();

  final StoreRepository _storeRepository = StoreRepository();

  final currentStore = Rxn<StoreModel>();
  final storeName = ''.obs;
  final storeDes = ''.obs;

  @override
  void onInit() {    
    super.onInit();
  }

  void updateCurrentStore(StoreModel updated) {
  currentStore.value = updated;
  storeNameController.text = updated.name;
  storeDesController.text = updated.description;
}


  void loadExistingStore(StoreModel store) {
    currentStore.value = store;
    storeNameController.text = store.name;
    storeDesController.text = store.description;
    update();
  }

  Future<void> saveStoreInfo() async {
    final name = storeNameController.text.trim();
    final description = storeDesController.text.trim();

    if (name.isEmpty || description.isEmpty || currentStore.value == null) {
      Get.snackbar("Lỗi", "Vui lòng nhập đầy đủ thông tin");
      return;
    }

    final updatedStore = currentStore.value!.copyWith(name: name, description: description);

    try {
      await _storeRepository.updateStore(updatedStore);
      currentStore.value = updatedStore;

      
      Get.snackbar("Thành công", "Đã cập nhật thông tin cửa hàng");
    } catch (e) {
      Get.snackbar("Lỗi", "Cập nhật thất bại: $e");
    }
  }

  @override
  void onClose() {
    storeNameController.dispose();
    storeDesController.dispose();
    currentStore.value = null;
    super.onClose();
  }
}
