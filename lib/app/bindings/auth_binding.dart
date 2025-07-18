import 'package:agrimarket/data/repo/cart_repo.dart';
import 'package:agrimarket/data/services/auth_service.dart';
import 'package:agrimarket/features/auth/viewmodel/email_verify_vm.dart';
import 'package:agrimarket/features/auth/viewmodel/login_vm.dart';
import 'package:agrimarket/features/auth/viewmodel/register_view_model.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/checkout_vm.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/discount_vm.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/payment_vm.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/buyer_home_vm.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/store_vm.dart';
import 'package:agrimarket/features/buyer/profile/viewmodel/address_list_vm.dart';
import 'package:agrimarket/features/buyer/profile/viewmodel/reset_password_vm.dart';
import 'package:agrimarket/features/buyer/other/viewmodel/add_address_vm.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:agrimarket/features/buyer/cart/viewmodel/cart_vm.dart';
import 'package:agrimarket/features/buyer/store/viewmodel/store_detail_vm.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:agrimarket/features/seller/menu/viewmodel/menu_screen_vm.dart';
import 'package:agrimarket/features/seller/orders/viewmodel/seller_orders_vm.dart';
import 'package:agrimarket/features/seller/other/viewmodel/create_store_vm.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:agrimarket/features/seller/product/viewmodel/seller_product_screen_vm.dart';
import 'package:agrimarket/features/seller/profile/viewmodel/store_info_vm.dart';
import 'package:agrimarket/features/seller/promotion/viewmodel/promotion_vm.dart';
import 'package:agrimarket/features/seller/revenue/viewmodel/revenue_vm.dart';
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
    Get.lazyPut<AddressListVm>(() => AddressListVm());
    Get.lazyPut<SellerMenuVm>(() => SellerMenuVm());
    Get.lazyPut<SellerProductVm>(() => SellerProductVm());
    Get.lazyPut<StoreVm>(() => StoreVm());
    Get.lazyPut<BuyerHomeScreenVm>(() => BuyerHomeScreenVm());
    Get.lazyPut<PromotionVm>(() => PromotionVm());
    Get.lazyPut<CartVm>(() => CartVm(CartRepository()));
    Get.lazyPut<SearchVm>(() => SearchVm());
    Get.put(StoreDetailVm(), permanent: true);
    Get.lazyPut<CheckoutVm>(() => CheckoutVm());
    Get.lazyPut<StoreInfoVm>(() => StoreInfoVm());
    Get.lazyPut<DiscountVm>(() => DiscountVm());
    Get.lazyPut<PaymentVm>(() => PaymentVm());
    Get.lazyPut<SellerOrdersVm>(() => SellerOrdersVm());
    Get.lazyPut<RevenueVm>(() => RevenueVm());
  }
}