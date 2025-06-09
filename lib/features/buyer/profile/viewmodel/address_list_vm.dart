import 'package:agrimarket/data/models/buyer.dart';
import 'package:agrimarket/data/providers/firestore_provider.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AddressListVm extends GetxController{
  final FirestoreProvider _firestoreProvider = FirestoreProvider();


 

  Future<void> deleteAddress(int indexToDelete) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      Get.snackbar('Lỗi', 'Người dùng chưa đăng nhập');
      return;
    }

    try {
      BuyerModel? buyer = await _firestoreProvider.getBuyerById(uid);
      if (buyer == null) return;

      final updatedAddresses = List<Address>.from(buyer.addresses);
      if (indexToDelete < 0 || indexToDelete >= updatedAddresses.length) {
        Get.snackbar('Lỗi', 'Không tìm thấy địa chỉ để xóa');
        return;
      }

      bool wasDefault = updatedAddresses[indexToDelete].isDefault;

      updatedAddresses.removeAt(indexToDelete);

      if (wasDefault && updatedAddresses.isNotEmpty) {
        updatedAddresses[0] = Address(
          label: updatedAddresses[0].label,
          address: updatedAddresses[0].address,
          latitude: updatedAddresses[0].latitude,
          longitude: updatedAddresses[0].longitude,
          isDefault: true,
        );
        
        for (int i = 1; i < updatedAddresses.length; i++) {
          updatedAddresses[i] = Address(
            label: updatedAddresses[i].label,
            address: updatedAddresses[i].address,
            latitude: updatedAddresses[i].latitude,
            longitude: updatedAddresses[i].longitude,
            isDefault: false,
          );
        }
      }

      final updatedBuyer = BuyerModel(
        uid: buyer.uid,
        favoriteStoreIds: buyer.favoriteStoreIds,
        addresses: updatedAddresses,
        reviews: buyer.reviews,
        orderIds: buyer.orderIds,
      );

      await _firestoreProvider.createBuyer(updatedBuyer);

      // Cập nhật lại dữ liệu buyer
      Get.find<BuyerVm>().fetchBuyerData();

      Get.snackbar('Thành công', 'Đã xóa địa chỉ');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa địa chỉ: $e');
    }
  }
}