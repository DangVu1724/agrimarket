import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:agrimarket/core/utils/security_utils.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
