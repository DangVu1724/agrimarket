import 'package:agrimarket/app/bindings/auth_binding.dart';
import 'package:agrimarket/app/bindings/buyer_binding.dart';
import 'package:agrimarket/app/bindings/seller_binding.dart';
import 'package:agrimarket/app/routes/middleware.dart';
import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/features/auth/view/dashboard.dart';
import 'package:agrimarket/features/auth/view/email_verify_screen.dart';
import 'package:agrimarket/features/auth/view/loading_screen.dart';
import 'package:agrimarket/features/buyer/chat/view/chat_list.dart';
import 'package:agrimarket/features/buyer/checkout/view/checkout_screen.dart';
import 'package:agrimarket/features/buyer/checkout/view/discount_code_screen.dart';
import 'package:agrimarket/features/buyer/checkout/view/payment_method_screen.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/checkout_vm.dart';
import 'package:agrimarket/features/buyer/home/view/category_store_screen.dart';
import 'package:agrimarket/features/buyer/home/view/hot_sale_screen.dart';
import 'package:agrimarket/features/buyer/home/view/promotion_store_list_screen.dart';
import 'package:agrimarket/features/buyer/other/view/add_address.dart';
import 'package:agrimarket/features/buyer/cart/view/cart_screen.dart';
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
import 'package:agrimarket/features/buyer/profile/view/voucher_screen.dart';
import 'package:agrimarket/features/buyer/search/view/search_screen.dart';
import 'package:agrimarket/features/buyer/profile/view/setting_screen.dart';
import 'package:agrimarket/features/buyer/store/view/product_detail_screen.dart';
import 'package:agrimarket/features/buyer/store/view/store_detail_screen.dart';
import 'package:agrimarket/features/buyer/store/view/store_screen.dart';
import 'package:agrimarket/features/seller/financial/view/financial_screen.dart';
import 'package:agrimarket/features/seller/menu/view/menu_screen.dart';
import 'package:agrimarket/features/seller/orders/view/orderList_screen.dart';
import 'package:agrimarket/features/seller/other/view/create_store_address.dart';
import 'package:agrimarket/features/seller/other/view/create_store_info.dart';
import 'package:agrimarket/features/seller/home/view/seller_home_screen.dart';
import 'package:agrimarket/features/seller/product/view/seller_create_product_screen.dart';
import 'package:agrimarket/features/seller/product/view/seller_product_details_screen.dart';
import 'package:agrimarket/features/seller/product/view/seller_product_screen.dart';
import 'package:agrimarket/features/seller/product/view/seller_update_product_screen.dart';
import 'package:agrimarket/features/seller/profile/view/profile_screen.dart';
import 'package:agrimarket/features/seller/profile/view/store_info_screen.dart';
import 'package:agrimarket/features/seller/promotion/view/promotion_screen.dart';
import 'package:agrimarket/features/seller/revenue/view/revenue_screen.dart';
import 'package:agrimarket/features/seller/seller_home.dart';
import 'package:get/get.dart';
import '../../features/auth/view/login_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    // ===== PUBLIC ROUTES (Không cần middleware) =====
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.dashboard, page: () => const Dashboard(), binding: AuthBinding()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.register, page: () => RegisterScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.emailVerify, page: () => EmailVerificationScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.roleSelection, page: () => RoleSelectionScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.resetPassword, page: () => ResetPasswordScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.loading, page: () => const ServerLoadingScreen(), binding: AuthBinding()),

    // ===== AUTHENTICATION ROUTES (Cần AuthMiddleware) =====
    GetPage(
      name: AppRoutes.addAddress,
      page: () => AddressScreen(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.createStoreInfo,
      page: () => CreateStoreInfoScreen(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.createStoreAddress,
      page: () => StoreAddressScreen(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // ===== BUYER ROUTES (Cần AuthMiddleware + BuyerBinding) =====
    GetPage(
      name: AppRoutes.buyerHome,
      page: () => BuyerHome(),
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.buyerHomeScreen,
      page: () => HomeBuyerScreen(),
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: AppRoutes.cart, page: () => CartScreen(), binding: BuyerBinding(), middlewares: [AuthMiddleware()]),
    GetPage(
      name: AppRoutes.buyerSearch,
      page: () => SearchScreen(),
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.buyerOrders,
      page: () => const OrdersScreen(),
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.buyerProfile,
      page: () => ProfileScreen(),
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.buyerAccount,
      page: () => AccountScreen(),
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.buyerAddress,
      page: () => AddressListScreen(),
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.favourite,
      page: () => FavouriteScreen(),
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.categoryStoreScreen,
      page: () => CategoryStoreScreen(),
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.storePromotionList,
      page: () => PromotionStoreListScreen(),
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    // Trong app_pages.dart
    GetPage(name: AppRoutes.hotSaleVerticalList, page: () => const HotSaleVerticalListScreen(), binding: BuyerBinding(), middlewares: [AuthMiddleware()]),
    GetPage(
      name: AppRoutes.paymentMethod,
      page: () => PaymentMethodScreen(),
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.checkOut,
      page: () {
        final String storeId = Get.arguments as String;
        return CheckoutScreen(storeId: storeId);
      },
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.discountCode,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        final String storeId = args['storeId'] as String;
        final double total = args['total'] as double;
        return DiscountCodeScreen(storeId: storeId, total: total);
      },
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.store,
      page: () {
        final store = Get.arguments;
        if (store is StoreModel) {
          return StoreScreen(store: store);
        } else {
          throw ArgumentError('Expected StoreModel as argument for StoreScreen');
        }
      },
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.storeDetail,
      page: () {
        final store = Get.arguments;
        if (store is StoreModel) {
          return StoreDetailScreen(store: store);
        } else {
          throw ArgumentError('Expected StoreModel as argument for StoreDetailScreen');
        }
      },
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.buyerProductDetail,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return ProductDetailScreen(
          product: ProductModel.fromJson(args['product']),
          store: StoreModel.fromJson(args['store']),
        );
      },
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.buyerChatList,
      page: () => BuyerChatListScreen(),
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.voucher,
      page: () => const VoucherScreen(),
      binding: BuyerBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // GetPage(
    //   name: AppRoutes.buyerChat,
    //   page: () => BuyerChatScreen(

    //   ),
    //   binding: BuyerBinding(),
    //   middlewares: [AuthMiddleware()],
    // ),

    // ===== SELLER ROUTES (Cần AuthMiddleware + SellerBinding) =====
    GetPage(
      name: AppRoutes.sellerHome,
      page: () => SellerHome(),
      binding: SellerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.sellerHomeScreen,
      page: () => const SellerHomeScreen(),
      binding: SellerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.sellerOrderList,
      page: () => const OrderlistScreen(),
      binding: SellerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.sellerMenu,
      page: () => SellerMenuScreen(),
      binding: SellerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.sellerProfile,
      page: () => SellerProfileScreen(),
      binding: SellerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.storeInfo,
      page: () => StoreInfoScreen(),
      binding: SellerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.sellerProduct,
      page: () => SellerProductScreen(),
      binding: SellerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.sellerCreateProduct,
      page: () => SellerCreateProductScreen(),
      binding: SellerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.sellerFinancial,
      page: () => const CommissionScreen(),
      binding: SellerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.revenue,
      page: () => RevenueScreen(),
      binding: SellerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.sellerProductDetail,
      page: () {
        final product = Get.arguments as ProductModel;
        return SellerProductDetailScreen(product: product);
      },
      binding: SellerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.sellerUpdateProduct,
      page: () {
        final product = Get.arguments as ProductModel;
        return SellerUpdateProductScreen(product: product);
      },
      binding: SellerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.sellerPromotions,
      page: () => SellerPromotionScreen(),
      binding: SellerBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // ===== COMMON ROUTES (Có thể dùng cho cả buyer và seller) =====
    GetPage(
      name: AppRoutes.aboutApp,
      page: () => AboutAppScreen(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: AppRoutes.help, page: () => HelpScreen(), binding: AuthBinding(), middlewares: [AuthMiddleware()]),
    GetPage(
      name: AppRoutes.security,
      page: () => SecurityScreen(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => PrivacyScreen(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => SettingScreen(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
