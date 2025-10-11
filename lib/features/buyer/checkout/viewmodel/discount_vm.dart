import 'package:agrimarket/data/models/discount_code.dart';
import 'package:agrimarket/data/models/user_vouchers.dart';
import 'package:agrimarket/data/services/promotion_service.dart';
import 'package:agrimarket/data/services/voucher_service.dart';
import 'package:get/get.dart';

class DiscountVm extends GetxController {
  final PromotionService promotionService = PromotionService();
  final VoucherService voucherService = VoucherService();

  // Discount
  final RxList<DiscountCodeModel> discountCodes = <DiscountCodeModel>[].obs;
  final Rx<DiscountCodeModel?> selectedDiscountCode = Rx<DiscountCodeModel?>(null);

  // Voucher
  final RxList<UserVoucherModel> vouchers = <UserVoucherModel>[].obs;
  final Rx<UserVoucherModel?> selectedVoucher = Rx<UserVoucherModel?>(null);

  final RxBool isLoadingDiscountCodes = false.obs;
  final RxBool isLoadingVouchers = false.obs;

  final RxString errorMessage = ''.obs;
  final RxBool hasInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVouchers();
  }

  Future<void> fetchDiscountCodes(String storeId) async {
    if (storeId.isEmpty) {
      errorMessage.value = 'Store ID không hợp lệ';
      return;
    }

    if (isLoadingDiscountCodes.value) return;

    isLoadingDiscountCodes.value = true;
    errorMessage.value = '';

    try {
      final codes = await promotionService.getAllDiscountCodes(storeId);
      discountCodes.assignAll(codes);
      selectedDiscountCode.value = null;
      hasInitialized.value = true;
    } catch (e) {
      errorMessage.value = 'Không thể tải mã giảm giá';
      discountCodes.clear();
      selectedDiscountCode.value = null;
    } finally {
      isLoadingDiscountCodes.value = false;
    }
  }

  Future<void> fetchVouchers() async {
    if (isLoadingVouchers.value) return;

    isLoadingVouchers.value = true;
    errorMessage.value = '';

    try {
      final vs = await voucherService.getAllVouchers(); 
      vouchers.assignAll(vs);
      selectedVoucher.value = null;
    } catch (e) {
      errorMessage.value = 'Không thể tải voucher';
      vouchers.clear();
      selectedVoucher.value = null;
    } finally {
      isLoadingVouchers.value = false;
    }
  }

  // Chọn discount
  void selectDiscountCode(DiscountCodeModel discountCode) {
    if (selectedDiscountCode.value?.id == discountCode.id) {
      selectedDiscountCode.value = null;
    } else {
      selectedDiscountCode.value = discountCode;
      selectedVoucher.value = null; // nếu chọn discount thì bỏ chọn voucher
    }
  }

  // Chọn voucher
  void selectVoucher(UserVoucherModel voucher) {
  if (selectedVoucher.value == voucher) {
    selectedVoucher.value = null;
  } else {
    selectedVoucher.value = voucher;
    selectedDiscountCode.value = null;
  }
}


  void clearAll() {
    discountCodes.clear();
    vouchers.clear();
    selectedDiscountCode.value = null;
    selectedVoucher.value = null;
    errorMessage.value = '';
    hasInitialized.value = false;
  }

  bool get hasSelectedDiscount => selectedDiscountCode.value != null;
  bool get hasSelectedVoucher => selectedVoucher.value != null;
}
