import 'package:agrimarket/data/models/discount_code.dart';
import 'package:agrimarket/data/services/promotion_service.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DiscountVm extends GetxController {
  final PromotionService promotionService = PromotionService();

  final RxList<DiscountCodeModel> discountCodes = <DiscountCodeModel>[].obs;
  final Rx<DiscountCodeModel?> selectedDiscountCode = Rx<DiscountCodeModel?>(null);
  final RxBool isLoadingDiscountCodes = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasInitialized = false.obs;

  final Box _box = Hive.box('discountCodeCache');

  @override
  void onInit() {
    super.onInit();
    // Remove automatic fetchDiscountCodes call from onInit
    // It will be called explicitly from the screen
  }

  Future<void> fetchDiscountCodes(String storeId) async {

    if (storeId.isEmpty) {
      errorMessage.value = 'Store ID không hợp lệ';
      return;
    }

    // Prevent multiple calls
    if (isLoadingDiscountCodes.value) {
      return;
    }

    isLoadingDiscountCodes.value = true;
    errorMessage.value = '';

    try {
      final codes = await promotionService.getAllDiscountCodes(storeId);

      discountCodes.assignAll(codes);

      // Load previously selected discount code if exists
      final selectedDiscountCodeId = _box.get('selectedDiscountCode');

      if (selectedDiscountCodeId != null) {
        final existingCode = discountCodes.where((code) => code.id == selectedDiscountCodeId).firstOrNull;
        if (existingCode != null) {
          selectedDiscountCode.value = existingCode;
        } else {
          // Clear invalid cached discount code
          _box.delete('selectedDiscountCode');
          selectedDiscountCode.value = null;
        }
      }

      hasInitialized.value = true;
    } catch (e) {
      errorMessage.value = 'Không thể tải mã giảm giá';
      discountCodes.clear();
      selectedDiscountCode.value = null;
    } finally {
      isLoadingDiscountCodes.value = false;
    }
  }

  void selectDiscountCode(DiscountCodeModel discountCode) {
    if (selectedDiscountCode.value?.id == discountCode.id) {
      selectedDiscountCode.value = null;
      _box.delete('selectedDiscountCode');
    } else {
      selectedDiscountCode.value = discountCode;
      _box.put('selectedDiscountCode', discountCode.id);
    }
  }

  void clearSelectedDiscountCode() {
    selectedDiscountCode.value = null;
    _box.delete('selectedDiscountCode');
  }

  void clearAll() {
    discountCodes.clear();
    selectedDiscountCode.value = null;
    errorMessage.value = '';
    hasInitialized.value = false;
    _box.delete('selectedDiscountCode');
  }

  bool get hasSelectedDiscountCode => selectedDiscountCode.value != null;
  String? get selectedDiscountCodeText => selectedDiscountCode.value?.code;
}
