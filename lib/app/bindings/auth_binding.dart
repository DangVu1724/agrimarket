import 'package:agrimarket/features/auth/viewmodel/email_verify_vm.dart';
import 'package:agrimarket/features/auth/viewmodel/login_vm.dart';
import 'package:agrimarket/features/auth/viewmodel/register_view_model.dart';
import 'package:agrimarket/features/auth/viewmodel/reset_password_vm.dart';
import 'package:agrimarket/features/buyer/viewmodel/home_vm.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<RegisterViewModel>(() => RegisterViewModel());
    Get.lazyPut<EmailVerificationViewModel>(() => EmailVerificationViewModel());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ResetPasswordViewModel>(() => ResetPasswordViewModel());
    Get.lazyPut<LoginViewModel>(() => LoginViewModel());
  }
}