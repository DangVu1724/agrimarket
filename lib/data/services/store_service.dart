import 'package:hive/hive.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/repo/store_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoreService {
  final StoreRepository _storeRepository = StoreRepository();
  final Box _box = Hive.box('storeCache');

  static const _cacheDuration = 10 * 60 * 1000; // 10 phút

  Future<StoreModel?> fetchStoreData() async {
    final local = _box.get('storeModel');
    if (local != null && local is StoreModel) return local;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final stores = await _storeRepository.getStoresByOwner(user.uid);
    if (stores.isEmpty) return null;

    final store = stores.first;
    _box.put('storeModel', store);
    return store;
  }

  void clearStoreCache() {
    _box.delete('storeModel');
  }

  Future<List<StoreModel>> getStoresWithCache() async {
    final cached = _box.get('stores_list');
    final timestamp = _box.get('stores_list_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cached != null && timestamp != null && now - timestamp < _cacheDuration) {
      try {
        return (cached as List)
            .map((s) => StoreModel.fromJson(Map<String, dynamic>.from(s)))
            .where((s) => s.state.toLowerCase() == 'verify')
            .toList();
      } catch (e) {
        _box.delete('stores_list');
        _box.delete('stores_list_timestamp');
      }
    }

    final stores = await fetchStores();
    final filtered = stores.where((s) => s.state.toLowerCase() == 'verify').toList();
    _box.put('stores_list', filtered.map((s) => s.toJson()).toList());
    _box.put('stores_list_timestamp', now);
    return filtered;
  }

  Future<List<StoreModel>> getStoresByCategoryWithCache(String category) async {
    final key = 'stores_category_$category';
    final timestampKey = '${key}_timestamp';
    final cached = _box.get(key);
    final timestamp = _box.get(timestampKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cached != null && timestamp != null && now - timestamp < _cacheDuration) {
      try {
        return (cached as List)
            .map((s) => StoreModel.fromJson(Map<String, dynamic>.from(s)))
            .where((s) => s.state.toLowerCase() == 'verify')
            .toList();
      } catch (e) {
        _box.delete(key);
        _box.delete(timestampKey);
      }
    }

    final stores = await fetchStoresByCategory(category);
    final filtered = stores.where((s) => s.state.toLowerCase() == 'verify').toList();
    _box.put(key, filtered.map((s) => s.toJson()).toList());
    _box.put(timestampKey, now);
    return filtered;
  }

  Future<StoreModel> getStoreByIdWithCache(String id) async {
    final key = 'store_$id';
    final timestampKey = '${key}_timestamp';
    final cached = _box.get(key);
    final timestamp = _box.get(timestampKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cached != null && timestamp != null && now - timestamp < _cacheDuration) {
      try {
        return StoreModel.fromJson(Map<String, dynamic>.from(cached));
      } catch (e) {
        _box.delete(key);
        _box.delete(timestampKey);
      }
    }

    final store = await _storeRepository.fetchStoresbyID(id);
    _box.put(key, store.toJson());
    _box.put(timestampKey, now);
    return store;
  }

  Future<List<StoreModel>> fetchStores() {
    return _storeRepository.fetchStores();
  }

  Future<List<StoreModel>> fetchStoresByCategory(String category) {
    return _storeRepository.fetchStoresByCategory(category);
  }

  Future<StoreModel> fetchStoresbyID(String storeId) {
    return _storeRepository.fetchStoresbyID(storeId);
  }

  void clearStoresCache() {
    _box.delete('stores_list');
    _box.delete('stores_list_timestamp');
  }
}

