import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String usersCollection = 'users';

  // Lưu thông tin user vào Firestore
  Future<void> createUser(UserModel userModel) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(userModel.uid)
          .set(userModel.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Lấy thông tin user từ Firestore
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Cập nhật thông tin user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Xóa user (hiếm khi dùng, nhưng cần cho admin)
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }
}
