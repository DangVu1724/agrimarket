import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/core/utils/security_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordViewModel extends GetxController {
  var newPassword = ''.obs;
  var confirmPassword = ''.obs;
  var isLoading = false.obs;
  final confirmPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final GlobalKey<FormState> formKeyResetPass = GlobalKey<FormState>();

  String? validatePassword(String? value) {
    return SecurityUtils.validatePassword(value);
  }

  String? validateConfirmPassword(String? value) {
    if (value != newPasswordController.text) return 'Mật khẩu không khớp';
    return null;
  }

  Future<void> updatePassword() async {
    if (!formKeyResetPass.currentState!.validate()) return;
    try {
      isLoading.value = true;

      User? user = FirebaseAuth.instance.currentUser;
      bool isGoogleUser = false;

      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
        print(user?.providerData.map((e) => e.providerId).toList());
        isGoogleUser = user!.providerData.any((provider) => provider.providerId == 'google.com');
      }

      if (isGoogleUser) {
        Get.snackbar('Lỗi', 'Bạn không thể đổi mật khẩu với tài khoản Google');
        return;
      }

      await user?.updatePassword(newPassword.value);
      await FirebaseAuth.instance.signOut();

      Get.snackbar('Thành công', 'Đổi mật khẩu thành công, vui lòng đăng nhập lại');
      Get.toNamed(AppRoutes.login);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Lỗi', e.message ?? 'Có lỗi xảy ra');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
