import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/auth_controller.dart';

class LoginViewModel extends GetxController {
  final AuthController _authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool obscureText = true.obs;
  final RxBool rememberMe = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
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
    if (!(formKey.currentState?.validate() ?? false)) return;
    
    isLoading.value = true;
    try {
      // Gọi signIn từ AuthController, không cần kiểm tra kết quả
      await _authController.signIn(
        email: emailController.text,
        password: passwordController.text,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void socialLogin(String provider) {
    Get.snackbar('Thông báo', '$provider login đang phát triển');
  }

  void navigateToRegister() {
    Get.toNamed(AppRoutes.register);
  }
}