import 'package:agrimarket/app/controllers/auth_controller.dart';
import 'package:agrimarket/core/utils/security_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterViewModel extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final obscurePassword = true.obs;
  final agreeTerms = false.obs;
  final isLoading = false.obs;
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
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    return null;
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

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (!SecurityUtils.isValidPhoneNumber(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  String? validatePassword(String? value) {
    return SecurityUtils.validatePassword(value);
  }

  Future<void> signUp() async {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      if (!agreeTerms.value) {
        errorMessage.value = 'Vui lòng đồng ý với Điều khoản dịch vụ và Chính sách bảo mật';
        return;
      }
      errorMessage.value = '';
      try {
        isLoading.value = true;

        final isTaken = await isPhoneNumberTaken(phoneController.text.trim());
        if (isTaken) {
          errorMessage.value = 'Số điện thoại đã được sử dụng';
          return;
        }

        await _authController.register(
          email: emailController.text.trim(),
          password: passwordController.text,
          name: fullNameController.text.trim(),
          phone: phoneController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage.value = 'Email đã được sử dụng.';
            break;
          case 'invalid-email':
            errorMessage.value = 'Email không hợp lệ.';
            break;
          case 'weak-password':
            errorMessage.value = 'Mật khẩu quá yếu.';
            break;
          case 'operation-not-allowed':
            errorMessage.value = 'Tài khoản email/password chưa được bật.';
            break;
          default:
            errorMessage.value = 'Đăng ký thất bại: ${e.message ?? e.code}';
        }
      } catch (e) {
        errorMessage.value = 'Đăng ký thất bại: $e';
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<bool> isPhoneNumberTaken(String phone) async {
    final querySnapshot = await FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: phone).get();

    return querySnapshot.docs.isNotEmpty;
  }

  void showErrorDialog(String message) {
    errorMessage.value = message;

    Future.delayed(const Duration(seconds: 3), () {
      if (errorMessage.value == message) {
        errorMessage.value = '';
      }
    });
  }
}
