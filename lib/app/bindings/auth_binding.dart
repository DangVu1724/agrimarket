import 'package:agrimarket/data/services/auth_service.dart';
import 'package:agrimarket/features/auth/viewmodel/email_verify_vm.dart';
import 'package:agrimarket/features/auth/viewmodel/login_vm.dart';
import 'package:agrimarket/features/auth/viewmodel/register_view_model.dart';
import 'package:agrimarket/features/buyer/viewmodel/reset_password_vm.dart';
import 'package:agrimarket/features/buyer/viewmodel/add_address_vm.dart';
import 'package:agrimarket/features/buyer/viewmodel/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/viewmodel/user_vm.dart';
import 'package:agrimarket/features/seller/viewmodel/create_store_vm.dart';
import 'package:agrimarket/features/seller/viewmodel/seller_home_vm.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<RegisterViewModel>(() => RegisterViewModel());
    Get.lazyPut<EmailVerificationViewModel>(() => EmailVerificationViewModel());
    Get.lazyPut<ResetPasswordViewModel>(() => ResetPasswordViewModel());
    Get.lazyPut<LoginViewModel>(() => LoginViewModel());
    Get.lazyPut<CreateStoreViewModel>(() => CreateStoreViewModel());
    Get.lazyPut<SellerHomeVm>(() => SellerHomeVm());
    Get.lazyPut<BuyerVm>(() => BuyerVm());
    Get.lazyPut<UserVm>(() => UserVm());
    Get.lazyPut<AddressViewModel>(() => AddressViewModel());
  }
}