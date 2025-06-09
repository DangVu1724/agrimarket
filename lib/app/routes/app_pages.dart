import 'package:agrimarket/app/bindings/auth_binding.dart';
import 'package:agrimarket/features/auth/view/dashboard.dart';
import 'package:agrimarket/features/auth/view/email_verify_screen.dart';
import 'package:agrimarket/features/buyer/other/view/add_address.dart';
import 'package:agrimarket/features/buyer/other/view/favourite_screen.dart';
import 'package:agrimarket/features/buyer/profile/view/about_app_screen.dart';
import 'package:agrimarket/features/buyer/profile/view/address_list_screen.dart';
import 'package:agrimarket/features/buyer/profile/view/helps_screen.dart';
import 'package:agrimarket/features/buyer/profile/view/privacy_screen.dart';
import 'package:agrimarket/features/buyer/profile/view/reset_password_screen.dart';
import 'package:agrimarket/features/auth/view/register_screen.dart';
import 'package:agrimarket/features/auth/view/role_selection_screen.dart';
import 'package:agrimarket/features/auth/view/splash_screen.dart';
import 'package:agrimarket/features/buyer/profile/view/account_screen.dart';
import 'package:agrimarket/features/buyer/buyer_home.dart';
import 'package:agrimarket/features/buyer/home/view/buyer_home_screen.dart';
import 'package:agrimarket/features/buyer/orders/view/order_screen.dart';
import 'package:agrimarket/features/buyer/profile/view/profile_screen.dart';
import 'package:agrimarket/features/buyer/profile/view/security_screen.dart';
import 'package:agrimarket/features/buyer/search/view/search_screen.dart';
import 'package:agrimarket/features/buyer/profile/view/setting_screen.dart';
import 'package:agrimarket/features/seller/menu/view/menu_screen.dart';
import 'package:agrimarket/features/seller/orders/view/orderList_screen.dart';
import 'package:agrimarket/features/seller/other/view/create_store_address.dart';
import 'package:agrimarket/features/seller/other/view/create_store_info.dart';
import 'package:agrimarket/features/seller/home/view/seller_home_screen.dart';
import 'package:agrimarket/features/seller/product/view/seller_create_product_screen.dart';
import 'package:agrimarket/features/seller/product/view/seller_product_screen.dart';
import 'package:agrimarket/features/seller/seller_home.dart';
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
      name: AppRoutes.aboutApp,
      page: () => AboutAppScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.help,
      page: () => HelpScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.security,
      page: () => SecurityScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => PrivacyScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => SettingScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.sellerHome,
      page: () => SellerHome(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.sellerHomeScreen,
      page: () => const SellerHomeScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.sellerOrderList,
      page: () => const OrderlistScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.sellerMenu,
      page: () => SellerMenuScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.sellerProduct,
      page: () => SellerProductScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.sellerCreateProduct,
      page: () => SellerCreateProductScreen(),
      binding: AuthBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.sellerProduct,
    //   page: () => SelllerProductScreen(),
    //   binding: AuthBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.sellerProduct,
    //   page: () => SelllerProductScreen(),
    //   binding: AuthBinding(),
    // ),

  ];
}