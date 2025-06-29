import 'package:agrimarket/data/models/cart.dart';
import 'package:get/get.dart';

class CheckoutVm extends GetxController{
  final RxList<CartItem> checkOutItems = <CartItem>[].obs;



  void setItems(List<CartItem> items) {
    checkOutItems.assignAll(items);
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