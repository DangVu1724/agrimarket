import 'package:agrimarket/data/models/buyer.dart';
import 'package:agrimarket/data/providers/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';


class BuyerVm extends GetxController {
  final FirestoreProvider firestoreProvider = FirestoreProvider();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  var isLoading = false.obs;

  final address = RxList<Address>();

  @override
  void onInit() {
    super.onInit();
    fetchBuyerData();
  }

  String get defaultAddress {
  if (address.isNotEmpty) {
    return address.firstWhere(
      (addr) => addr.isDefault,
      orElse: () => address.first,
    ).address;
  }
  return 'Chưa có địa chỉ';
}


  void fetchBuyerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    try {
      isLoading.value = true;

      final buyerData = await firestoreProvider.getBuyerById(user.uid);
      if (buyerData != null) {
        if (buyerData.addresses.isNotEmpty) {
          address.assignAll(buyerData.addresses);
          print('Addresses loaded: ${buyerData.addresses.length}');
        } else {
          address.clear();
        }
        print('User data loaded: ${buyerData.toJson()}');
      } else {
        Get.snackbar('Error', 'Buyer data not found');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }
}
