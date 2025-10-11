import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/order_service.dart';
import 'package:agrimarket/data/services/simple_notification_service.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/cart/viewmodel/cart_vm.dart';
import 'package:agrimarket/features/buyer/checkout/viewmodel/discount_vm.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CheckoutVm extends GetxController {
    final CartVm cartVm = Get.find<CartVm>();

  final RxList<CartItem> checkOutItems = <CartItem>[].obs;
  final Rx<StoreModel?> store = Rx<StoreModel?>(null);
  final RxBool isLoadingStore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasInitialized = false.obs;
  final RxBool isCreatingOrder = false.obs;
  final RxDouble discountPrice = 0.0.obs;
  final int serviceFee = 5000;
  final int shippingFee = 20000;

  final StoreService storeService = StoreService();
  final OrderService orderService = OrderService();
  final UserVm userVm = Get.find<UserVm>();
  final BuyerVm buyerVm = Get.find<BuyerVm>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final NotificationService notificationService = NotificationService();
  final DiscountVm discountVm = Get.find<DiscountVm>();

  @override
  void onInit() {
    super.onInit();
    userVm.loadUserData();
    buyerVm.fetchBuyerData();
    checkOutItems.assignAll(cartVm.cart.value?.items ?? []);
    ever(cartVm.cart, (cart) {
      checkOutItems.assignAll(cart?.items ?? []);
    });
  
  }

  Future<void> getStore(String storeId) async {
    if (storeId.isEmpty) {
      errorMessage.value = 'Store ID không hợp lệ';
      return;
    }

    // Prevent multiple calls for the same store
    if (isLoadingStore.value) return;

    isLoadingStore.value = true;
    errorMessage.value = '';

    try {
      final fetchedStore = await storeService.fetchStoresbyID(storeId);
      store.value = fetchedStore;
      hasInitialized.value = true;
    } catch (e) {
      print('Error fetching store: $e');
      errorMessage.value = 'Không thể tải thông tin cửa hàng';
      store.value = null;
    } finally {
      isLoadingStore.value = false;
    }
  }

  void clearStore() {
    store.value = null;
    errorMessage.value = '';
    hasInitialized.value = false;
  }

  Future<String?> createOrder(Map<String, dynamic> orderData) async {
    try {
      final orderId = await notificationService.createOrder(orderData);

      if (orderId != null) {
        print('✅ Order created successfully: $orderId');
      } else {
        print('❌ Failed to create order');
      }

      return orderId;
    } catch (e) {
      print('❌ Exception in CheckoutVm.createOrder: $e');
      return null;
    }
  }

  double get subTotal {
    double total = 0;
    for (var item in checkOutItems) {
      final price =
          (item.isOnSaleAtAddition ?? false) ? (item.promotionPrice ?? item.priceAtAddition) : item.priceAtAddition;
      total += price * item.quantity.value;
    }
    return total;
  }

  double get discountAmount {
    // Ưu tiên discount code
    if (discountVm.hasSelectedDiscount) {
      final code = discountVm.selectedDiscountCode.value!;
      if (code.discountType == 'fixed') return code.value.toDouble();
      if (code.discountType == 'percent') return subTotal * code.value / 100;
    }

    // Nếu không có discount code thì check voucher
    if (discountVm.hasSelectedVoucher) {
      final voucher = discountVm.selectedVoucher.value!;
      if (voucher.discountType == 'fixed') return voucher.discountValue.toDouble();
      if (voucher.discountType == 'percentage') return subTotal * voucher.discountValue / 100;
      return voucher.discountValue.toDouble();
    }

    return 0;
  }

  double get total => subTotal + serviceFee + shippingFee - discountAmount;
}
