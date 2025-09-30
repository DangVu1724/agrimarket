import 'package:agrimarket/core/constants/env_config.dart';
import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/order_service.dart';
import 'package:agrimarket/data/services/simple_notification_service.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CheckoutVm extends GetxController {
  final RxList<CartItem> checkOutItems = <CartItem>[].obs;
  final Rx<StoreModel?> store = Rx<StoreModel?>(null);
  final RxBool isLoadingStore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasInitialized = false.obs;
  final RxBool isCreatingOrder = false.obs;

  final StoreService storeService = StoreService();
  final OrderService orderService = OrderService();
  final UserVm userVm = Get.find<UserVm>();
  final BuyerVm buyerVm = Get.find<BuyerVm>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final NotificationService notificationService = NotificationService();

  @override
  void onInit() {
    super.onInit();
    userVm.loadUserData();
    buyerVm.fetchBuyerData();
  }

  void setItems(List<CartItem> items) {
    checkOutItems.assignAll(items);
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
      final orderId = await notificationService.createOrder(
        orderData,
      );

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



  double get totalPrice {
    double total = 0;
    for (var item in checkOutItems) {
      final price =
          (item.isOnSaleAtAddition ?? false) ? (item.promotionPrice ?? item.priceAtAddition) : item.priceAtAddition;
      total += price * item.quantity.value;
    }
    return total;
  }
}