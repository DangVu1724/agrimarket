import 'package:agrimarket/features/seller/financial/viewmodel/financial_vm.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:agrimarket/features/seller/menu/viewmodel/menu_screen_vm.dart';
import 'package:agrimarket/features/seller/orders/viewmodel/seller_orders_vm.dart';
import 'package:agrimarket/features/seller/other/viewmodel/create_store_vm.dart';
import 'package:agrimarket/features/seller/product/viewmodel/seller_product_screen_vm.dart';
import 'package:agrimarket/features/seller/profile/viewmodel/reset_password_vm.dart';
import 'package:agrimarket/features/seller/profile/viewmodel/store_info_vm.dart';
import 'package:agrimarket/features/seller/promotion/viewmodel/promotion_vm.dart';
import 'package:agrimarket/features/seller/revenue/viewmodel/revenue_vm.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:get/get.dart';

class SellerBinding extends Bindings {
  @override
  void dependencies() {
    // Core seller dependencies
    Get.lazyPut<SellerHomeVm>(() => SellerHomeVm());
    Get.lazyPut<UserVm>(() => UserVm());

    // Home & Store
    Get.lazyPut<SellerHomeVm>(() => SellerHomeVm());
    Get.lazyPut<StoreInfoVm>(() => StoreInfoVm());

    // Product Management
    Get.lazyPut<SellerProductVm>(() => SellerProductVm());

    // Menu Management
    Get.lazyPut<SellerMenuVm>(() => SellerMenuVm());

    // Orders
    Get.lazyPut<SellerOrdersVm>(() => SellerOrdersVm());

    // Financial & Revenue
    Get.lazyPut<CommissionVm>(() => CommissionVm());
    Get.lazyPut<RevenueVm>(() => RevenueVm());

    // Promotions
    Get.lazyPut<PromotionVm>(() => PromotionVm());

    // Store Creation
    Get.lazyPut<CreateStoreViewModel>(() => CreateStoreViewModel());

    // Profile & Settings
    Get.lazyPut<ResetPasswordViewModel>(() => ResetPasswordViewModel());
  }
}
