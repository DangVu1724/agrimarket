import 'package:agrimarket/data/models/user_vouchers.dart';
import 'package:agrimarket/data/models/vouchers_catalog.dart';
import 'package:agrimarket/data/services/voucher_service.dart';
import 'package:get/get.dart';

class VoucherVm extends GetxController {
  final RxList<VoucherModel> vouchers = <VoucherModel>[].obs;
  final RxList<UserVoucherModel> userVouchers = <UserVoucherModel>[].obs;

  final VoucherService _voucherService = VoucherService();

  @override
  void onInit() {
    super.onInit();
    _voucherService.getVouchersStream().listen((data) {
      vouchers.value = data;
    });

    _voucherService.getUserVouchersStream().listen((data) {
      userVouchers.value = data;
    });
  }

  Future<VoucherModel?> getVoucherDetail(UserVoucherModel userVoucher) async {
    return await _voucherService.getVoucherByUserVoucher(userVoucher);
  }

  Future<Map<String, dynamic>?> redeemVoucher(String voucherId) async {
    final result = await _voucherService.redeemVoucher(voucherId);
    return result;
  }
}
