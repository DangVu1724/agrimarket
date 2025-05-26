import 'package:agrimarket/app/bindings/auth_binding.dart';
import 'package:agrimarket/features/auth/view/dashboard.dart';
import 'package:agrimarket/features/auth/view/email_verify_screen.dart';
import 'package:agrimarket/features/auth/view/reset_password_screen.dart';
import 'package:agrimarket/features/auth/view/register_screen.dart';
import 'package:agrimarket/features/auth/view/role_selection_screen.dart';
import 'package:agrimarket/features/auth/view/splash_screen.dart';
import 'package:agrimarket/features/buyer/view/add_address.dart';
import 'package:agrimarket/features/buyer/view/home_screen.dart';
import 'package:get/get.dart';
import '../../features/auth/view/login_screen.dart';
import 'app_routes.dart';


class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const Dashboard(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () =>  ResetPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () =>  RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => RoleSelectionScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.addAddress,
      page: () => AddressScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.emailVerify,
      page: () => EmailVerificationScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.buyerHome,
      page: () =>  HomeBuyerScreen(),
      binding: AuthBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.sellerHome,
    //   page: () => const HomeSellerScreen(),
    //   binding: AuthBinding(),
    // ),
  ];
}