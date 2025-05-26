import 'package:agrimarket/app/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (!RegExp(r'^0[0-9]{9}$').hasMatch(value)) {
      return 'Số điện thoại phải bắt đầu bằng 0 và có 10 chữ số';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  Future<void> signUp() async {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      if (!agreeTerms.value) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng đồng ý với Điều khoản dịch vụ và Chính sách bảo mật',
        );
        return;
      }

      try {
        isLoading.value = true;

        final isTaken = await isPhoneNumberTaken(phoneController.text.trim());
        if (isTaken) {
          Get.snackbar('Lỗi', 'Số điện thoại đã được sử dụng');
          return;
        }

        await _authController.register(
          email: emailController.text.trim(),
          password: passwordController.text,
          name: fullNameController.text.trim(),
          phone: phoneController.text.trim(),
        );
      } catch (e) {
        Get.snackbar('Lỗi', 'Đăng ký thất bại: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<bool> isPhoneNumberTaken(String phone) async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: phone)
            .get();

    return querySnapshot.docs.isNotEmpty;
  }
}
