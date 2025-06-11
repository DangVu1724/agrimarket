import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:get/get.dart';

class StoreVm extends GetxController {
  final StoreService _storeService = StoreService();

  final RxList<StoreModel> storesByCategory = <StoreModel>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> fetchStoresByCategory(String category) async {
    try {
      isLoading.value = true;
      final stores = await _storeService.fetchStoresByCategory(category);
      storesByCategory.assignAll(stores);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải cửa hàng theo danh mục: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    storesByCategory.clear();
    super.onClose();
  }
}