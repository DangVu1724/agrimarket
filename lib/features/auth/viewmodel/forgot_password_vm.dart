import 'package:agrimarket/core/utils/security_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ForgotPasswordViewModel extends GetxController {
  final RxString email = ''.obs;
  final RxBool isLoading = false.obs;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập email';
    if (!SecurityUtils.isValidEmail(value)) return 'Email không hợp lệ';
    return null;
  }
}
