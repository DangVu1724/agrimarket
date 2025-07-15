import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:get/get.dart';

class StoreVm extends GetxController {
  final StoreService _storeService = StoreService();

  final RxList<StoreModel> storesByCategory = <StoreModel>[].obs;
  final RxList<StoreModel> storesList = <StoreModel>[].obs;
  final RxList<StoreModel> storesListPromotion = <StoreModel>[].obs;
  final Rxn<StoreModel> storeData = Rxn<StoreModel>();
  final RxBool isLoading = false.obs;
  final filterType = 'all'.obs;
  final isAscending = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStoresList();
    fetchStoresWithPromotion();
  }

  Future<void> fetchStoresList() async {
    try {
      isLoading.value = true;
      final stores = await _storeService.getStoresWithCache();
      storesList.assignAll(stores);
    } catch (e) {
      storesList.clear();
      Get.snackbar('Lỗi', 'Không thể tải danh sách cửa hàng: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStoresList() async {
    _storeService.clearStoresCache();
    await fetchStoresList();
  }

  Future<void> fetchStoresByCategory(String category) async {
    try {
      print('🔍 ViewModel: Starting to fetch stores for category: $category');
      isLoading.value = true;
      final stores = await _storeService.getStoresByCategoryWithCache(category);
      print('📦 ViewModel: Received ${stores.length} stores from service');
      storesByCategory.assignAll(stores);
      print('✅ ViewModel: Successfully assigned ${storesByCategory.length} stores');
    } catch (e) {
      print('❌ ViewModel error: $e');
      storesByCategory.clear();
      Get.snackbar('Lỗi', 'Không thể tải cửa hàng theo danh mục: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStoreByID(String id) async {
    try {
      isLoading.value = true;
      final store = await _storeService.getStoreByIdWithCache(id);
      storeData.value = store;
    } catch (e) {
      storeData.value = null;
      Get.snackbar('Lỗi', 'Không thể tải cửa hàng: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStoresWithPromotion() async {
    try {
      isLoading.value = true;
      final stores = await _storeService.getStoresWithPromotion();
      storesListPromotion.assignAll(stores);
    } catch (e) {
      storesListPromotion.clear();
      Get.snackbar('Lỗi', 'Không thể tải danh sách cửa hàng khuyến mãi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String value) => filterType.value = value;

  void toggleSortOrder() => isAscending.value = !isAscending.value;

  List<StoreModel> getFilteredStores() {
    var list = storesByCategory.toList();
    if (filterType.value == 'opened') {
      list = list.where((s) => s.isOpened).toList();
    } else if (filterType.value == 'promotion') {
      list = list.where((s) => s.isPromotion).toList();
    }
    list.sort((a, b) => isAscending.value ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    return list;
  }

  @override
  void onClose() {
    storesByCategory.clear();
    super.onClose();
  }

  // Debug method
  Future<void> debugAllStores() async {
    await _storeService.debugAllStores();
  }
}
