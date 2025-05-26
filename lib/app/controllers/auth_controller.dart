import 'package:agrimarket/data/providers/firestore_provider.dart';
import 'package:agrimarket/data/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import '../routes/app_routes.dart';


class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirestoreProvider _firestoreProvider = FirestoreProvider();

  var isLoading = false.obs;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // 1. Đăng nhập với Firebase Auth
      final user = await _authService.signInWithEmailAndPassword(email, password);

      if (user != null) {
        // 2. Kiểm tra email đã xác minh chưa
        final isEmailVerified = await _authService.isEmailVerified();

        if (!isEmailVerified) {
          // Chuyển đến màn hình xác minh email
          Get.offAllNamed(AppRoutes.emailVerify);
          Get.snackbar(
            'Xác minh email',
            'Vui lòng xác minh email trước khi tiếp tục.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // 3. Lấy thông tin người dùng từ Firestore
        final userModel = await _firestoreProvider.getUserById(user.uid);

        if (userModel == null) {
          throw Exception('Không tìm thấy thông tin người dùng');
        }

        // 4. Điều hướng dựa trên vai trò
        if (userModel.role == null) {
          Get.offAllNamed(AppRoutes.roleSelection);
        } else {
          Get.offAllNamed(
            userModel.role == 'buyer' ? AppRoutes.buyerHome : AppRoutes.sellerHome,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Không tìm thấy tài khoản với email này';
          break;
        case 'wrong-password':
          errorMessage = 'Mật khẩu không đúng';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ';
          break;
        case 'user-disabled':
          errorMessage = 'Tài khoản đã bị vô hiệu hóa';
          break;
        default:
          errorMessage = 'Đã có lỗi xảy ra: ${e.message ?? e.toString()}';
      }
      Get.snackbar('Lỗi', errorMessage);
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã có lỗi không xác định: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Đăng ký và lưu thông tin người dùng
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      isLoading.value = true;

      // 1. Đăng ký tài khoản Firebase Auth
      final user = await _authService.registerWithEmailAndPassword(email, password);

      if (user != null) {
        // 2. Gửi email xác minh
        await _authService.sendEmailVerification(user);

        // 3. Lưu thông tin người dùng vào Firestore
        final userModel = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          phone: phone,
          role: null, details: null, 
        );
        await _firestoreProvider.createUser(userModel);

        // 4. Chuyển sang màn chọn vai trò
        Get.offAllNamed(AppRoutes.emailVerify);
      }
    } catch (e) {
      Get.snackbar("Lỗi", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Xác minh email trước khi tiếp tục
  Future<void> checkEmailVerificationAndProceed() async {
    final verified = await _authService.isEmailVerified();
    if (verified) {
      // Tiếp tục tới chọn role
      Get.offAllNamed(AppRoutes.roleSelection);
    } else {
      Get.snackbar("Xác minh email", "Vui lòng xác minh email trước khi tiếp tục.");
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    await _authService.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> updateUserRole(String role) async {
  try {
    isLoading.value = true;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }
    // Lấy thông tin user hiện tại
    final currentUserDoc = await _firestoreProvider.getUserById(user.uid);
    if (currentUserDoc == null) {
      throw Exception('Không tìm thấy thông tin người dùng');
    }
    // Cập nhật role mới và khởi tạo details rỗng tùy theo role
    Map<String, dynamic> updateData = {
      'role': role,
      'details': role == 'buyer' ? {} : {}, 
    };
    await _firestoreProvider.updateUser(user.uid, updateData);
  } catch (e) {
    Get.snackbar("Lỗi", e.toString());
  } finally {
    isLoading.value = false;
  }
}
}
