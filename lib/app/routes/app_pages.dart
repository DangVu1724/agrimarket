import 'package:agrimarket/app/bindings/auth_binding.dart';
import 'package:agrimarket/features/auth/view/dashboard.dart';
import 'package:agrimarket/features/auth/view/email_verify_screen.dart';
import 'package:agrimarket/features/buyer/view/reset_password_screen.dart';
import 'package:agrimarket/features/auth/view/register_screen.dart';
import 'package:agrimarket/features/auth/view/role_selection_screen.dart';
import 'package:agrimarket/features/auth/view/splash_screen.dart';
import 'package:agrimarket/features/buyer/view/account_screen.dart';
import 'package:agrimarket/features/buyer/view/add_address.dart';
import 'package:agrimarket/features/buyer/view/address_list_screen.dart';
import 'package:agrimarket/features/buyer/view/buyer_home.dart';
import 'package:agrimarket/features/buyer/view/buyer_home_screen.dart';
import 'package:agrimarket/features/buyer/view/favourite_screen.dart';
import 'package:agrimarket/features/buyer/view/order_screen.dart';
import 'package:agrimarket/features/buyer/view/profile_screen.dart';
import 'package:agrimarket/features/buyer/view/search_screen.dart';
import 'package:agrimarket/features/buyer/view/setting_screen.dart';
import 'package:agrimarket/features/seller/view/create_store_address.dart';
import 'package:agrimarket/features/seller/view/create_store_info.dart';
import 'package:agrimarket/features/seller/view/seller_home.dart';
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
      name: AppRoutes.createStoreInfo,
      page: () => StoreInfoScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.createStoreAddress,
      page: () => StoreAddressScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.emailVerify,
      page: () => EmailVerificationScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.buyerHome,
      page: () =>  BuyerHome(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.buyerHomeScreen,
      page: () =>  HomeBuyerScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.buyerOrders,
      page: () => const OrdersScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.buyerSearch,
      page: () => const SearchScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.buyerProfile,
      page: () => ProfileScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.buyerAccount,
      page: () => AccountScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.buyerAddress,
      page: () => AddressListScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.favourite,
      page: () => FavouriteScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => SettingScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.sellerHome,
      page: () => const SellerHomeScreen(),
      binding: AuthBinding(),
    ),
  ];
}