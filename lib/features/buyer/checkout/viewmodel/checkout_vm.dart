import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/order_service.dart';
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

  Future<String?> createOrder({
    required String storeId,
    required String storeName,
    required String buyerName,
    required String buyerPhone,
    required List<CartItem> items,
    required String paymentMethod,
    required String deliveryAddress,
    String? discountCodeId,
    double? discountPrice,
    bool? isPaid,
    bool? isCommissionPaid,
  }) async {
    if (items.isEmpty) {
      throw Exception('Không có sản phẩm nào trong đơn hàng');
    }

    if (paymentMethod.isEmpty) {
      throw Exception('Vui lòng chọn phương thức thanh toán');
    }

    if (deliveryAddress.isEmpty) {
      throw Exception('Vui lòng nhập địa chỉ giao hàng');
    }

    if (buyerName.isEmpty) {
      throw Exception('Vui lòng nhập tên người mua');
    }

    if (buyerPhone.isEmpty) {
      throw Exception('Vui lòng nhập số điện thoại người mua');
    }

    isCreatingOrder.value = true;
    errorMessage.value = '';

    try {
      // Convert CartItems to OrderItems
      final orderItems =
          items
              .map(
                (item) => OrderItem(
                  productId: item.productId,
                  name: item.productName,
                  quantity: item.quantity.value,
                  price: item.priceAtAddition,
                  unit: item.unit,
                  promotionPrice: item.promotionPrice,
                ),
              )
              .toList();

      // Calculate total price
      double totalPrice = 0;
      for (final item in items) {
        final price =
            (item.isOnSaleAtAddition ?? false) && item.promotionPrice != null
                ? item.promotionPrice!
                : item.priceAtAddition;
        totalPrice += price * item.quantity.value;
      }

      // Add service fee and shipping fee
      final serviceFee = 5000;
      final shippingFee = 20000;
      final finalTotal = totalPrice + serviceFee + shippingFee - (discountPrice ?? 0);


      // Create order
      final order = OrderModel(
        orderId: '',
        buyerUid: auth.currentUser?.uid ?? '',
        storeId: storeId,
        storeName: storeName,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
        items: orderItems,
        status: 'pending', // Initial status
        paymentMethod: paymentMethod,
        totalPrice: finalTotal,
        discountPrice: discountPrice,
        createdAt: DateTime.now(),
        deliveryAddress: deliveryAddress,
        discountCodeId: discountCodeId,
        isPaid: isPaid,
        isCommissionPaid: isCommissionPaid,
      );

      final orderId = await orderService.createOrder(order);
      print('Order created successfully with ID: $orderId');

      return orderId;
    } catch (e) {
      print('Error creating order: $e');
      errorMessage.value = 'Không thể tạo đơn hàng: $e';
      return null;
    } finally {
      isCreatingOrder.value = false;
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
