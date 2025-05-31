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


  Future<void> updatePassword() async {
    if (newPassword.value.isEmpty || confirmPassword.value.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập đầy đủ thông tin');
      return;
    }
    if (newPassword.value != confirmPassword.value) {
      Get.snackbar('Lỗi', 'Mật khẩu xác nhận không khớp');
      return;
    }

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
      Get.offAllNamed(AppRoutes.login);

    } on FirebaseAuthException catch (e) {
      Get.snackbar('Lỗi', e.message ?? 'Có lỗi xảy ra');
    } finally {
      isLoading.value = false;
    }
  }
}
