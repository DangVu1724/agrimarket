import 'package:agrimarket/data/providers/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';


class BuyerVm extends GetxController {
  final FirestoreProvider firestoreProvider = FirestoreProvider();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  var isLoading = false.obs;

  final address = RxString('');

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  void fetchUserData() async {
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
          address.value = buyerData.addresses[0].address;
        } else {
          address.value = 'Chưa có địa chỉ';
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
