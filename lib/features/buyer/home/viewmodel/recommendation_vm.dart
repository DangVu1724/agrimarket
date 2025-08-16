import 'package:agrimarket/data/models/buyer.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/recommendation_service.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class RecommendationVm extends GetxController {
  final RecommendationService _service = RecommendationService();
  final StoreService _storeService = StoreService();

  final RxList<StoreModel> recommendedStores = <StoreModel>[].obs;
  final RxList<StoreModel> nearbyStores =  <StoreModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final buyerVm = Get.find<BuyerVm>();
    final buyer = buyerVm.buyerData.value;
    if (buyer != null) {
      final addr = buyer.addresses.isNotEmpty
          ? buyer.addresses.firstWhere((a) => a.isDefault, orElse: () => buyer.addresses.first)
          : null;
      fetchRecommendations(lat: addr?.latitude, lng: addr?.longitude);
      fetchNearbyStore(lat: addr?.latitude, lng: addr?.longitude);
    }
    ever<BuyerModel?>(buyerVm.buyerData, (buyer) {
      if (buyer != null) {
        final addr = buyer.addresses.isNotEmpty
            ? buyer.addresses.firstWhere((a) => a.isDefault, orElse: () => buyer.addresses.first)
            : null;
        fetchRecommendations(lat: addr?.latitude, lng: addr?.longitude);
        fetchNearbyStore(lat: addr?.latitude, lng: addr?.longitude);

      }
    });
  }

  Future<void> fetchRecommendations({double? lat, double? lng}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;

      final ids = await _service.fetchRecommendedStoreIds(lat: lat, lng: lng);

      if (ids.isEmpty) {
        recommendedStores.clear();
        return;
      }

      print('Fetched IDs: $ids');

      final stores = await _storeService.fetchStoresByIds(ids);
      recommendedStores.assignAll(stores);
    } catch (e) {
      print('Error fetching recommendations: $e');
      recommendedStores.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNearbyStore({double? lat, double? lng}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;

      final ids = await _service.fetchNearbyStoreIds(
        lat: lat ?? 0.0,
        lng: lng ?? 0.0,
      );

      if (ids.isEmpty) {
        nearbyStores.clear();
        return;
      }

      print('Fetched IDs: $ids');

      final stores = await _storeService.fetchStoresByIds(ids);
      nearbyStores.assignAll(stores);
    } catch (e) {
      print('Error fetching nearby stores: $e');
      nearbyStores.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
