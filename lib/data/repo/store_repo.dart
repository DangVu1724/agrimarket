import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:get/get.dart';

class StoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createStore(StoreModel store) async {
    try {
      await _firestore.collection('stores').doc(store.storeId).set(store.toJson());
    } catch (e) {
      throw Exception('Lỗi khi lưu thông tin cửa hàng: $e');
    }
  }

  Future<void> updateStore(StoreModel store) async {
    try {
      await _firestore.collection('stores').doc(store.storeId).update(store.toJson());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật thông tin cửa hàng: $e');
    }
  }

  Future<List<StoreModel>> getStoresByOwner(String ownerUid) async {
    try {
      final querySnapshot = await _firestore.collection('stores').where('ownerUid', isEqualTo: ownerUid).get();
      return querySnapshot.docs.map((doc) => StoreModel.fromJson(doc.data())).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<StoreModel> fetchStoresbyID(String storeID) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('stores').doc(storeID).get();

      if (querySnapshot.exists) {
        return StoreModel.fromJson({...querySnapshot.data() as Map<String, dynamic>, 'storeId': querySnapshot.id});
      } else {
        Get.snackbar('Lỗi', 'Không tìm thấy cửa hàng');
        throw Exception('Store not found');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách cửa hàng: $e');
      rethrow;
    }
  }

  Future<List<StoreModel>> fetchStores() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('stores').get();

      return querySnapshot.docs.map((doc) => StoreModel.fromJson({...doc.data(), 'storeId': doc.id})).toList();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách cửa hàng: $e');
      return [];
    }
  }

  Future<List<StoreModel>> fetchStoresByCategory(String category) async {
    try {
      print('🔍 Repository: Searching for stores with category: $category');

      final querySnapshot =
          await FirebaseFirestore.instance.collection('stores').where('categories', arrayContains: category).get();

      print('🌐 Repository: Found ${querySnapshot.docs.length} documents from Firestore');

      final stores =
          querySnapshot.docs.map((doc) {
            final data = {...doc.data(), 'storeId': doc.id};
            print(
              '📄 Document ${doc.id}: ${data['name']} - State: ${data['state']} - Categories: ${data['categories']}',
            );
            return StoreModel.fromJson(data);
          }).toList();

      print('✅ Repository: Successfully parsed ${stores.length} stores');
      return stores;
    } catch (e) {
      print('❌ Repository error: $e');
      Get.snackbar('Lỗi', 'Không thể tải danh sách cửa hàng: $e');
      return [];
    }
  }

  // Debug method to check all stores
  Future<void> debugAllStores() async {
    try {
      print('🔍 Debug: Fetching all stores from database');
      final querySnapshot = await FirebaseFirestore.instance.collection('stores').get();
      print('🌐 Debug: Total stores in database: ${querySnapshot.docs.length}');

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        print('📄 Debug Store: ${data['name']} - State: ${data['state']} - Categories: ${data['categories']}');
      }
    } catch (e) {
      print('❌ Debug error: $e');
    }
  }
}
