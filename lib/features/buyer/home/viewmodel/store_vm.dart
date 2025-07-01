import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class StoreVm extends GetxController {
  final StoreService _storeService = StoreService();
  final Box _cacheBox = Hive.box('storeCache');

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
    final cachedStores = _cacheBox.get('stores_list');
    final cacheTimestamp = _cacheBox.get('stores_list_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;
    const cacheDuration = 10 * 60 * 1000;

    if (cachedStores != null && cacheTimestamp != null && now - cacheTimestamp < cacheDuration) {
      try {
        final parsedStores = (cachedStores as List)
            .map((s) => StoreModel.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList();
        storesList.assignAll(parsedStores);
        print('Loaded ${parsedStores.length} stores from cache');
        return;
      } catch (e) {
        print('Error parsing cached stores: $e');
        await _cacheBox.delete('stores_list');
        await _cacheBox.delete('stores_list_timestamp');
      }
    }

    try {
      isLoading.value = true;
      final stores = await _storeService.fetchStores();
      final filteredStores = _filterPendingStores(stores);
      storesList.assignAll(filteredStores);

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

  bool loadStoresFromCacheOnly() {
    final cachedStores = _cacheBox.get('stores_list');
    final cacheTimestamp = _cacheBox.get('stores_list_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;
    const cacheDuration = 10 * 60 * 1000;

    if (cachedStores != null && cacheTimestamp != null && now - cacheTimestamp < cacheDuration) {
      try {
        final parsedStores = (cachedStores as List)
            .map((s) => StoreModel.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList();
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
      try {
        final parsedStores = (cachedStores as List)
            .map((s) => StoreModel.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList();
        storesByCategory.assignAll(parsedStores);
        print('Loaded ${parsedStores.length} stores for category $category from cache');
        return;
      } catch (e) {
        print('Error parsing cached category stores: $e');
        _cacheBox.delete(cacheKey);
        _cacheBox.delete('${cacheKey}_timestamp');
      }
    }

    try {
      isLoading.value = true;
      final stores = await _storeService.fetchStoresByCategory(category);
      final filteredStores = _filterPendingStores(stores);
      storesByCategory.assignAll(filteredStores);

      if (filteredStores.isNotEmpty) {
        await _cacheBox.put(cacheKey, filteredStores.map((s) => s.toJson()).toList());
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
      try {
        final store = StoreModel.fromJson(Map<String, dynamic>.from(cachedStore));
        storeData.value = store;
        print('Loaded store $id from cache');
        return store;
      } catch (e) {
        print('Error parsing cached store $id: $e');
        _cacheBox.delete(cacheKey);
        _cacheBox.delete('${cacheKey}_timestamp');
      }
    }

    try {
      isLoading.value = true;
      final store = await _storeService.fetchStoresbyID(id);
      storeData.value = store;

      if (store != null) {
        await _cacheBox.put(cacheKey, store.toJson());
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

    if (filterType.value == 'opened') {
      list = list.where((s) => s.isOpened).toList();
    } else if (filterType.value == 'certified') {
      list = list.where((s) => s.foodSafetyCertificateUrl != null).toList();
    }

    list.sort((a, b) => isAscending.value ? a.name.compareTo(b.name) : b.name.compareTo(a.name));

    return list;
  }

  @override
  void onClose() {
    storesByCategory.clear();
    super.onClose();
  }
}