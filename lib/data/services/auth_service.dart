import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:agrimarket/core/utils/security_utils.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;

  
  Future<void> saveFcmTokenToBuyer(String uid) async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken != null) {
    await _firestore.collection('buyers').doc(uid).set({
      'fcmTokens': [fcmToken]
    }, SetOptions(merge: true));
  }
}

Future<void> saveFcmTokenToStore(String uid) async {
  final fcmToken = await FirebaseMessaging.instance.getToken();

  if (fcmToken != null) {
    // Tìm document trong stores mà có owner = uid
    final query = await _firestore
        .collection('stores')
        .where('ownerUid', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final storeId = query.docs.first.id; 
      
      await _firestore
          .collection('stores')
          .doc(storeId)
          .set({
            'fcmTokens': FieldValue.arrayUnion([fcmToken]),
          }, SetOptions(merge: true));
    } else {
      print('Không tìm thấy store cho user $uid');
    }
  }
}




  // Đăng ký
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      // Validate input
      if (!SecurityUtils.isValidEmail(email)) {
        throw Exception('Email không hợp lệ');
      }

      final passwordError = SecurityUtils.validatePassword(password);
      if (passwordError != null) {
        throw Exception(passwordError);
      }

      // Sanitize input
      final sanitizedEmail = SecurityUtils.sanitizeInput(email);

      final credential = await _auth.createUserWithEmailAndPassword(email: sanitizedEmail, password: password);
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Đăng nhập
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Validate input
      if (!SecurityUtils.isValidEmail(email)) {
        throw Exception('Email không hợp lệ');
      }

      // Sanitize input
      final sanitizedEmail = SecurityUtils.sanitizeInput(email);

      final credential = await _auth.signInWithEmailAndPassword(email: sanitizedEmail, password: password);
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Gửi xác minh
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Kiểm tra xác minh
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  // Gửi reset
  Future<void> sendResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.back();
    } catch (e) {
      rethrow;
    }
  }

  // Google Sign-in
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }
}
