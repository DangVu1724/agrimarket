import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PaymentVm extends GetxController {
  final RxString paymentMethod = ''.obs;
  final Box _box = Hive.box('payment_method');

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethod();
  }

  void loadPaymentMethod() {
    try {
      final savedMethod = _box.get('payment_method');
      if (savedMethod != null && savedMethod is String) {
        paymentMethod.value = savedMethod;
      }
    } catch (e) {
      paymentMethod.value = '';
    }
  }

  void setPaymentMethod(String method) {
    try {
      paymentMethod.value = method;

      if (method.isNotEmpty) {
        _box.put('payment_method', method);
      } else {
        _box.delete('payment_method');
      }
    } catch (e) {}
  }

  void clearPaymentMethod() {
    setPaymentMethod('');
  }

  bool get hasPaymentMethod => paymentMethod.value.isNotEmpty;
}
