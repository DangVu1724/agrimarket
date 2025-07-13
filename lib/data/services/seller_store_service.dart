import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/repo/store_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerStoreService {
  final StoreRepository _storeRepository = StoreRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<StoreModel?> getCurrentSellerStore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      // Get stores directly from Firestore without cache
      final stores = await _storeRepository.getStoresByOwner(user.uid);

      for (int i = 0; i < stores.length; i++) {}

      if (stores.isEmpty) {
        return null;
      }

      final sellerStore = stores.first;
      return sellerStore;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getCurrentSellerStoreId() async {
    try {
      final store = await getCurrentSellerStore();
      return store?.storeId;
    } catch (e) {
      print('❌ Error getting seller store ID: $e');
      return null;
    }
  }

  Future<List<StoreModel>> getAllCurrentSellerStores() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return [];
      }

      print('🔍 Getting all stores for seller: ${user.uid}');
      final stores = await _storeRepository.getStoresByOwner(user.uid);
      print('✅ Found ${stores.length} stores for seller: ${user.uid}');
      return stores;
    } catch (e) {
      print('❌ Error getting all seller stores: $e');
      return [];
    }
  }

  // Get store by specific ID (for verification)
  Future<StoreModel?> getStoreById(String storeId) async {
    try {
      print('🔍 Getting store by ID: $storeId');
      final store = await _storeRepository.fetchStoresbyID(storeId);
      print('✅ Found store: ${store.storeId} - ${store.name}');
      return store;
    } catch (e) {
      print('❌ Error getting store by ID: $e');
      return null;
    }
  }
}
