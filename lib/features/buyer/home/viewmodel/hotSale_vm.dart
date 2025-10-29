import 'package:agrimarket/data/models/promotion_campaign.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/hot_sale_service.dart';
import 'package:get/get.dart';

class HotsaleVm extends GetxController {
  final HotSaleService _hotSaleService = HotSaleService();
  Rxn<PromotionCampaignModel?> currentHotSale = Rxn<PromotionCampaignModel>();
  RxList<StoreModel> hotSaleStores = RxList<StoreModel>([]);
  RxBool isLoading = false.obs;
  RxString remainingTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    listenToHotSale();
  }

  void listenToHotSale(){
    isLoading.value = true;
    _hotSaleService.getCurrentHotSaleStream().listen((hotSale) {
      
      currentHotSale.value = hotSale;
      if (hotSale != null) {
        _listenToHotSaleStores(hotSale.stores);
        _startCountdown(hotSale.endTime);
      } else {
        hotSaleStores.clear();
        isLoading.value = false;
      }
    });
  }

  void _listenToHotSaleStores(List<String> storeIds) {
    _hotSaleService.getStoresByIds(storeIds).listen((storesData) {
      final stores = storesData.map((s) => StoreModel.fromJson(s)).toList();
 
      hotSaleStores.assignAll(stores);
      isLoading.value = false;
    });
  }

  void _startCountdown(DateTime endTime) async {
    while (true) {
      final diff = endTime.difference(DateTime.now());
      if (diff.isNegative) {
        remainingTime.value = "Đã kết thúc";
        break;
      }
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      final seconds = diff.inSeconds % 60;
      remainingTime.value =
          "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}