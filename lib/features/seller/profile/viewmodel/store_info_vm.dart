import 'package:agrimarket/data/models/store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreInfoVm extends GetxController {
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController storeDesController = TextEditingController();
  
  late final StoreModel currentStore;
  final storeName = ''.obs;
  final storeDes = ''.obs;

  void loadExistingStore(StoreModel store) {
    currentStore = store;
    storeNameController.text = store.name;
    storeDesController.text = store.description; 
  }
  
}
