import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrimarket/data/models/user.dart';
import 'package:agrimarket/data/models/buyer.dart'; 
import 'package:agrimarket/data/models/store.dart';

class FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lưu thông tin người dùng
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
    } catch (e) {
      throw Exception('Lỗi khi lưu thông tin người dùng: $e');
    }
  }

  // Lấy thông tin người dùng theo UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin người dùng: $e');
    }
  }

  // Lưu thông tin BuyerModel
  Future<void> createBuyer(BuyerModel buyer) async {
    try {
      await _firestore.collection('buyers').doc(buyer.uid).set(buyer.toJson());
    } catch (e) {
      throw Exception('Lỗi khi lưu thông tin buyer: $e');
    }
  }

  // Lấy thông tin BuyerModel theo UID
  Future<BuyerModel?> getBuyerById(String uid) async {
    try {
      final doc = await _firestore.collection('buyers').doc(uid).get();
      if (doc.exists) {
        return BuyerModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin buyer: $e');
    }
  }

  Future<void> updateBuyer(String uid, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('buyers').doc(uid).update(data);
}


  Future<List<StoreModel>> getStoresByOwner(String ownerUid) async {
    try {
      final querySnapshot = await _firestore
          .collection('stores')
          .where('ownerUid', isEqualTo: ownerUid)
          .get();
      return querySnapshot.docs
          .map((doc) => StoreModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting stores: $e');
      rethrow;
    }
  }

  // Lưu thông tin cửa hàng
  Future<void> createStore(StoreModel store) async {
    try {
      await _firestore.collection('stores').doc(store.storeId).set(store.toJson());
    } catch (e) {
      throw Exception('Lỗi khi lưu thông tin cửa hàng: $e');
    }
  }
}