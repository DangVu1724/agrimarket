import 'dart:async';
import 'package:agrimarket/data/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:agrimarket/app/routes/app_routes.dart';

class EmailVerificationViewModel extends GetxController {
  final AuthService _authService = Get.find<AuthService>(); // inject bằng GetX

  final isEmailVerified = false.obs;
  final isLoading = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    _checkEmail();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkEmail());
  }

  Future<void> _checkEmail() async {
    final verified = await _authService.checkEmailVerified();
    if (verified) {
      isEmailVerified.value = true;
      _timer?.cancel();
      Get.offAllNamed(AppRoutes.roleSelection);
    }
  }

  Future<void> resendEmailVerification() async {
    try {
      isLoading.value = true;
      await _authService.sendEmailVerification();
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
