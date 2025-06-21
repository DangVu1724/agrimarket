import 'package:agrimarket/data/services/store_service.dart';
import 'package:get/get.dart';

class StoreVm extends GetxController {
  final RxBool isLoading = false.obs;

  final _storeService = StoreService();

  Future<void> fetchStores(String storeID) async {
    isLoading.value = true;
    try {
      await _storeService.fetchStoresbyID(storeID);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load stores: $e');
    } finally {
      isLoading.value = false;
    }
  }
 
}