import 'package:agrimarket/data/repo/cart_repo.dart';
import 'package:agrimarket/features/buyer/buyer_vm.dart';
import 'package:agrimarket/features/buyer/cart/viewmodel/cart_vm.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/checkout_vm.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/discount_vm.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/payment_vm.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/buyer_home_vm.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/store_vm.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/recommendation_vm.dart';
import 'package:agrimarket/features/buyer/orders/viewmodel/buyer_order_vm.dart';
import 'package:agrimarket/features/buyer/other/viewmodel/add_address_vm.dart';
import 'package:agrimarket/features/buyer/profile/viewmodel/address_list_vm.dart';
import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:agrimarket/features/buyer/store/viewmodel/store_detail_vm.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:get/get.dart';

class BuyerBinding extends Bindings {
  @override
  void dependencies() {
    // Core buyer dependencies
    Get.lazyPut<BuyerVm>(() => BuyerVm());
    Get.lazyPut<UserVm>(() => UserVm());

    // Home & Store
    Get.lazyPut<BuyerHomeScreenVm>(() => BuyerHomeScreenVm());
    Get.lazyPut<StoreVm>(() => StoreVm());
    Get.lazyPut<RecommendationVm>(() => RecommendationVm());
    Get.put(StoreDetailVm(), permanent: true);

    // Cart & Checkout
    Get.lazyPut<CartVm>(() => CartVm(CartRepository()));
    Get.lazyPut<CheckoutVm>(() => CheckoutVm());
    Get.lazyPut<DiscountVm>(() => DiscountVm());
    Get.lazyPut<PaymentVm>(() => PaymentVm());

    // Orders
    Get.lazyPut<BuyerOrderVm>(() => BuyerOrderVm());

    // Search
    Get.lazyPut<SearchVm>(() => SearchVm());

    // Address management
    Get.lazyPut<AddressViewModel>(() => AddressViewModel());
    Get.lazyPut<AddressListVm>(() => AddressListVm());
  }
}
