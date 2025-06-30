import 'package:agrimarket/app/routes/app_routes.dart';
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
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu phải ít nhất 6 ký tự';
    return null;
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

      if (user == null) {
        Get.snackbar('Lỗi', 'Bạn cần đăng nhập lại để đổi mật khẩu');
        return;
      }

      await user.updatePassword(newPassword.value);
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
