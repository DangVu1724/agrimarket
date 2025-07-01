import 'package:agrimarket/data/models/cart.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:get/get.dart';

class CheckoutVm extends GetxController{
  final RxList<CartItem> checkOutItems = <CartItem>[].obs;
  final Rx<StoreModel?> store = Rx<StoreModel?>(null);

  final StoreService storeService = StoreService();

  void setItems(List<CartItem> items) {
    checkOutItems.assignAll(items);
  }

  Future<void> getStore(String storeId) async {
    try {
      final fetchedStore = await storeService.fetchStoresbyID(storeId);
      store.value = fetchedStore;
    } catch (e) {
      print('Error fetching store: $e');
      store.value = null;
    }
  }

  double get totalPrice {
    double total = 0;
    for (var item in checkOutItems) {
      final price = (item.isOnSaleAtAddition ?? false)
          ? (item.promotionPrice ?? item.priceAtAddition)
          : item.priceAtAddition;
      total += price * item.quantity.value;
    }
    return total;
  } 
}