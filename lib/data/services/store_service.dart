import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/providers/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StoreService {
  final FirestoreProvider _firestoreProvider = FirestoreProvider();
  final GetStorage _storage = GetStorage();

  Future<StoreModel?> fetchStoreData() async {
    final local = _storage.read('storeModel');
    if (local != null) {
      return StoreModel.fromJson(Map<String, dynamic>.from(local));
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Lỗi', 'Chưa đăng nhập');
      return null;
    }

    final stores = await _firestoreProvider.getStoresByOwner(user.uid);
    if (stores.isEmpty) {
      Get.snackbar('Lỗi', 'Không có cửa hàng');
      return null;
    }

    final store = stores.first;
    _storage.write('storeModel', store.toJson());
    return store;
  }

  Future<List<StoreModel>> fetchStoresByCategory(String category) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('stores')
              .where('categories', arrayContains: category)
              .get();

      return querySnapshot.docs
          .map((doc) => StoreModel.fromJson({...doc.data(), 'storeId': doc.id}))
          .toList();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách cửa hàng: $e');
      return [];
    }
  }
}
