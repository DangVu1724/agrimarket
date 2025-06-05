import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  // Đăng ký tài khoản với email và password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Gửi email xác minh
  Future<void> sendEmailVerification(User user) async {
    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Kiểm tra trạng thái xác minh
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> sendResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.back();
    } catch (e) {
      rethrow;
    }
  }

  // Lấy current user
  User? get currentUser => _auth.currentUser;

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Bước 1: Người dùng chọn tài khoản Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Người dùng hủy đăng nhập
        return null;
      }

      // Bước 2: Lấy authentication object từ googleUser
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Bước 3: Tạo credential cho Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Bước 4: Đăng nhập Firebase với credential trên
      final userCredential = await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }
}
