import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ForgotPasswordViewModel extends GetxController {
  final RxString email = ''.obs;
  final RxBool isLoading = false.obs;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập email';
    if (!GetUtils.isEmail(value)) return 'Email không hợp lệ';
    return null;
  }

  Future<void> sendPasswordReset(String text) async {
    if (validateEmail(email.value) != null) {
      Get.snackbar('Lỗi', 'Vui lòng nhập email hợp lệ');
      return;
    }

    isLoading.value = true;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.value);
      Get.back(); // Đóng dialog
      Get.snackbar(
        'Thành công',
        'Email đặt lại mật khẩu đã được gửi tới ${email.value}',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Get.offAllNamed(AppRoutes.resetPassword);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Không tìm thấy tài khoản với email này';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ';
          break;
        default:
          errorMessage = 'Đã có lỗi xảy ra: ${e.toString()}';
      }
      Get.snackbar('Lỗi', errorMessage);
    } finally {
      isLoading.value = false;
    }
  }
}