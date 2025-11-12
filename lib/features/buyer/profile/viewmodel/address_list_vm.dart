import 'package:agrimarket/data/repo/address_repo.dart';
import 'package:agrimarket/features/buyer/buyer_vm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AddressListVm extends GetxController {
  final AddressRepository _buyerRepo = AddressRepository();

  Future<void> deleteAddress(int indexToDelete) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Get.snackbar('Lỗi', 'Người dùng chưa đăng nhập');
      return;
    }

    try {
      await _buyerRepo.deleteAddress(uid, indexToDelete);

      // Cập nhật lại dữ liệu buyer
      Get.find<BuyerVm>().fetchBuyerData();

      Get.snackbar('Thành công', 'Đã xóa địa chỉ');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa địa chỉ: $e');
    }
  }
}
