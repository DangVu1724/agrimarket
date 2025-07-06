import 'package:agrimarket/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _userBox = Hive.box('userCache');

  static const _cacheDuration = 10 * 60 * 1000; // 10 phút

  User? get currentUser => _auth.currentUser;

  /// Lấy user từ Firestore (có cache)
  Future<UserModel?> getUserData() async {
    if (currentUser == null) return null;

    final uid = currentUser!.uid;
    final cached = _userBox.get('user_$uid');
    final timestamp = _userBox.get('user_${uid}_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;

    // Kiểm tra cache
    if (cached != null && timestamp != null && now - timestamp < _cacheDuration) {
      try {
        return cached as UserModel;
      } catch (e) {
        _userBox.delete('user_$uid');
        _userBox.delete('user_${uid}_timestamp');
      }
    }

    // Nếu cache hết hạn, lấy từ Firestore
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    final userModel = UserModel.fromJson(doc.data() as Map<String, dynamic>);

    // Lưu vào cache
    _userBox.put('user_$uid', userModel);
    _userBox.put('user_${uid}_timestamp', now);

    return userModel;
  }

  /// Cập nhật tên và số điện thoại
  Future<void> updateProfile({
    required String newName,
    required String newPhone,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not logged in');

    await user.updateDisplayName(newName);
    await _firestore.collection('users').doc(user.uid).update({
      'name': newName,
      'phone': newPhone,
    });

    // Cập nhật cache
    final cachedUser = _userBox.get('user_${user.uid}') as UserModel?;
    if (cachedUser != null) {
      final updatedUser = UserModel(
        uid: cachedUser.uid,
        email: cachedUser.email,
        name: newName,
        phone: newPhone,
        role: cachedUser.role,
        createdAt: cachedUser.createdAt,
      );
      _userBox.put('user_${user.uid}', updatedUser);
      _userBox.put('user_${user.uid}_timestamp', DateTime.now().millisecondsSinceEpoch);
    }
  }

  /// Đăng xuất 
  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;

    if (uid != null) {
      _userBox.delete('user_$uid');
      _userBox.delete('user_${uid}_timestamp');
    }

    await _auth.signOut();

    final google = GoogleSignIn();
    if (await google.isSignedIn()) {
      await google.disconnect();
      await google.signOut();
    }
  }

  void clearUserCache() {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      _userBox.delete('user_$uid');
      _userBox.delete('user_${uid}_timestamp');
    }
  }

  /// Lấy user từ cache (không gọi Firestore)
  UserModel? getUserFromCache() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _userBox.get('user_$uid') as UserModel?;
  }
}
