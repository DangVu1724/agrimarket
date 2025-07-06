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
      final querySnapshot =
          await FirebaseFirestore.instance.collection('stores').where('categories', arrayContains: category).get();

      return querySnapshot.docs.map((doc) => StoreModel.fromJson({...doc.data(), 'storeId': doc.id})).toList();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách cửa hàng: $e');
      return [];
    }
  }
}
