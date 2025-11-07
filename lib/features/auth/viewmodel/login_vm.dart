import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/core/utils/security_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/controllers/auth_controller.dart';

class LoginViewModel extends GetxController {
  final AuthController _authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool obscureText = true.obs;
  final RxBool rememberMe = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    ever<String>(errorMessage, (msg) {
      if (msg.isNotEmpty) {
        Future.delayed(const Duration(seconds: 3), () {
          if (errorMessage.value == msg) {
            errorMessage.value = '';
          }
        });
      }
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void showErrorDialog(String message) {
    errorMessage.value = message;

    Future.delayed(const Duration(seconds: 3), () {
      if (errorMessage.value == message) {
        errorMessage.value = '';
      }
    });
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!SecurityUtils.isValidEmail(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    return null;
  }

  void toggleText() {
    obscureText.value = !obscureText.value;
  }

  


  void toggleRememberMe(bool value) {
    rememberMe.value = value;
    // TODO: Lưu trạng thái rememberMe (ví dụ: SharedPreferences)
  }

  Future<void> login() async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      await _authController.signIn(email: emailController.text.trim(), password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          errorMessage.value = 'Tài khoản không tồn tại. Vui lòng kiểm tra email.';
          break;

        case 'user-disabled':
          errorMessage.value = 'Tài khoản đã bị vô hiệu hóa. Vui lòng liên hệ hỗ trợ.';
          break;
        case 'too-many-requests':
          errorMessage.value = 'Quá nhiều lần thử đăng nhập. Vui lòng chờ một lát rồi thử lại.';
          break;
        case 'invalid-credential':
          errorMessage.value = 'Thông tin đăng nhập không hợp lệ. Vui lòng kiểm tra lại.';
          break;
        case 'account-exists-with-different-credential':
          errorMessage.value = 'Tài khoản đã tồn tại với phương thức đăng nhập khác.';
          break;
        case 'operation-not-allowed':
          errorMessage.value = 'Đăng nhập bằng email/mật khẩu đã bị tắt. Vui lòng liên hệ quản trị viên.';
          break;
        case 'network-request-failed':
          errorMessage.value = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.';
          break;
        case 'email-already-in-use':
          errorMessage.value = 'Email này đã được sử dụng. Vui lòng chọn email khác.';
          break;
        default:
          print('Firebase Login Error Code: ${e.code}');
          errorMessage.value = 'Đăng nhập thất bại: ${e.message ?? 'Lỗi không xác định'}';
      }
    } catch (e) {
      errorMessage.value = 'Đã xảy ra lỗi: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void socialLoginGoogle(String provider) {
    _authController.signInWithGoogle();
  }

  void socialLogin(String provider) {
    errorMessage.value = 'Chức năng này hiện chưa được hỗ trợ.';
  }
}
