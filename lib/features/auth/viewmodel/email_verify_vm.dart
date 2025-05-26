import 'dart:async';
import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class EmailVerificationViewModel extends GetxController {
  final isEmailVerified = false.obs;
  final isLoading = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _checkEmailVerified();
    _timer = Timer.periodic(Duration(seconds: 3), (_) => _checkEmailVerified());
  }

  Future<void> _checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      isEmailVerified.value = true;
      _timer?.cancel();
      Get.offAllNamed(AppRoutes.roleSelection); 
    }
  }

  Future<void> resendEmailVerification() async {
    try {
      isLoading.value = true;
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      Get.snackbar('Thành công', 'Đã gửi lại email xác minh');
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
