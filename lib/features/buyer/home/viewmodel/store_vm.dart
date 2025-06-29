import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class StoreVm extends GetxController {
  final StoreService _storeService = StoreService();
  final Box _cacheBox = Hive.box('storeCache'); // Dùng chung box với StoreDetailVm

  final RxList<StoreModel> storesByCategory = <StoreModel>[].obs;
  final RxList<StoreModel> storesList = <StoreModel>[].obs;
  final RxBool isLoading = false.obs;
  final filterType = 'all'.obs;
  final isAscending = true.obs;

  var storeData = Rxn<StoreModel>();

  List<StoreModel> _filterPendingStores(List<StoreModel> stores) {
    return stores.where((store) => store.state.toLowerCase() == 'verify').toList();
  }

  Future<void> fetchStoresList() async {
    // Kiểm tra cache trước
    final cachedStores = _cacheBox.get('stores_list');
    final cacheTimestamp = _cacheBox.get('stores_list_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;
    const cacheDuration = 10 * 60 * 1000;

    if (cachedStores != null && cacheTimestamp != null && now - cacheTimestamp < cacheDuration) {
      try {
        final parsedStores =
            (cachedStores as List<dynamic>).map((s) => StoreModel.fromJson(Map<String, dynamic>.from(s))).toList();
        storesList.assignAll(parsedStores);
        print('Loaded ${parsedStores.length} stores from cache');
        return;
      } catch (e) {
        print('Error parsing cached stores: $e');
        await _cacheBox.delete('stores_list');
        await _cacheBox.delete('stores_list_timestamp');
      }
    }

    // Fetch từ server nếu không có cache hoặc cache hết hạn
    try {
      isLoading.value = true;
      final stores = await _storeService.fetchStores();
      final filteredStores = _filterPendingStores(stores);
      storesList.assignAll(filteredStores);

      // Lưu vào cache
      if (filteredStores.isNotEmpty) {
        await _cacheBox.put('stores_list', filteredStores.map((s) => s.toJson()).toList());
        await _cacheBox.put('stores_list_timestamp', now);
        print('Fetched and cached ${filteredStores.length} stores');
      } else {
        storesList.clear();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách cửa hàng: $e', snackPosition: SnackPosition.BOTTOM);
      storesList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Phương thức chỉ lấy từ cache
  bool loadStoresFromCacheOnly() {
    final cachedStores = _cacheBox.get('stores_list');
    final cacheTimestamp = _cacheBox.get('stores_list_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;
    const cacheDuration = 10 * 60 * 1000;

    if (cachedStores != null && cacheTimestamp != null && now - cacheTimestamp < cacheDuration) {
      try {
        final parsedStores =
            (cachedStores as List<dynamic>).map((s) => StoreModel.fromJson(Map<String, dynamic>.from(s))).toList();
        storesList.assignAll(parsedStores);
        print('Loaded ${parsedStores.length} stores from cache');
        return true;
      } catch (e) {
        print('Error parsing cached stores: $e');
        _cacheBox.delete('stores_list');
        _cacheBox.delete('stores_list_timestamp');
      }
    }
    return false;
  }

  // Phương thức làm mới, xóa cache và fetch lại
  Future<void> refreshStoresList() async {
    await _cacheBox.delete('stores_list');
    await _cacheBox.delete('stores_list_timestamp');
    await fetchStoresList();
  }

  Future<void> fetchStoresByCategory(String category) async {
    final cacheKey = 'stores_category_$category';
    final cachedStores = _cacheBox.get(cacheKey);
    final cacheTimestamp = _cacheBox.get('${cacheKey}_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;
    const cacheDuration = 10 * 60 * 1000;

    if (cachedStores != null && cacheTimestamp != null && now - cacheTimestamp < cacheDuration) {
      storesByCategory.assignAll(cachedStores.cast<StoreModel>());
      print('Loaded ${cachedStores.length} stores for category $category from cache');
      return;
    }

    try {
      isLoading.value = true;
      final stores = await _storeService.fetchStoresByCategory(category);
      final filteredStores = _filterPendingStores(stores);
      storesByCategory.assignAll(filteredStores);

      if (filteredStores.isNotEmpty) {
        await _cacheBox.put(cacheKey, filteredStores);
        await _cacheBox.put('${cacheKey}_timestamp', now);
        print('Fetched and cached ${filteredStores.length} stores for category $category');
      } else {
        storesByCategory.clear();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải cửa hàng theo danh mục: $e', snackPosition: SnackPosition.BOTTOM);
      storesByCategory.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<StoreModel> fetchStoreByID(String id) async {
    final cacheKey = 'store_$id';
    final cachedStore = _cacheBox.get(cacheKey);
    final cacheTimestamp = _cacheBox.get('${cacheKey}_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;
    const cacheDuration = 10 * 60 * 1000;

    if (cachedStore != null && cacheTimestamp != null && now - cacheTimestamp < cacheDuration) {
      storeData.value = cachedStore as StoreModel;
      print('Loaded store $id from cache');
      return storeData.value!;
    }

    try {
      isLoading.value = true;
      final store = await _storeService.fetchStoresbyID(id);
      storeData.value = store;

      if (store != null) {
        await _cacheBox.put(cacheKey, store);
        await _cacheBox.put('${cacheKey}_timestamp', now);
        print('Fetched and cached store $id');
        return store;
      } else {
        storeData.value = null;
        throw Exception('Store not found');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải cửa hàng: $e', snackPosition: SnackPosition.BOTTOM);
      storeData.value = null;
      throw Exception('Failed to fetch store: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String value) {
    filterType.value = value;
  }

  void toggleSortOrder() {
    isAscending.value = !isAscending.value;
  }

  List<StoreModel> getFilteredStores() {
    var list = storesByCategory.toList();

    // Lọc theo filter
    if (filterType.value == 'opened') {
      list = list.where((s) => s.isOpened).toList();
    } else if (filterType.value == 'certified') {
      list = list.where((s) => s.foodSafetyCertificateUrl != null).toList();
    }

    // Sắp xếp theo tên
    list.sort((a, b) => isAscending.value ? a.name.compareTo(b.name) : b.name.compareTo(a.name));

    return list;
  }

  @override
  void onClose() {
    storesByCategory.clear();
    super.onClose();
  }
}
