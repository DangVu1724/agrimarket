import 'package:agrimarket/data/models/buyer.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/repo/buyer_repo.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/store_vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class BuyerVm extends GetxController {
  final BuyerRepository _buyerRepository = BuyerRepository();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final StoreVm storeVm = Get.find<StoreVm>();
  var isLoading = false.obs;

  final address = RxList<Address>();
  final favoriteStoreId = <String>[].obs;
  final favoriteStores = <StoreModel>[].obs;
  final buyerData = Rxn<BuyerModel>();

  @override
  void onInit() {
    super.onInit();
    fetchBuyerData();
  }

  Address? get defaultAddress { 
    if (address.isNotEmpty) {
    return address.firstWhere(
      (addr) => addr.isDefault,
      orElse: () => address.first,
    );
  }
  return null;
  }

  void fetchBuyerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }
    try {
      isLoading.value = true;

      final buyer = await _buyerRepository.getBuyerById(user.uid);
      buyerData.value = buyer;
      if (buyer != null) {
        if (buyer.addresses.isNotEmpty) {
          address.assignAll(buyer.addresses);
          favoriteStoreId.assignAll(buyer.favoriteStoreIds);
        } else {
          address.clear();
        }
      } else {
        Get.snackbar('Error', 'Buyer data not found');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBuyer(Map<String, dynamic> newData) async {
    final user = auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    try {
      isLoading.value = true;
      await _buyerRepository.updateBuyer(user.uid, newData);
      Get.snackbar('Thành công', 'Cập nhật thông tin thành công');

      fetchBuyerData();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavoriteStore(String storeId) async {
    final user = auth.currentUser;
    if (user == null) {
      Get.snackbar('Lỗi', 'Bạn chưa đăng nhập');
      return;
    }

    try {
      isLoading.value = true;

      final buyerData = await _buyerRepository.getBuyerById(user.uid);
      if (buyerData == null) {
        Get.snackbar('Lỗi', 'Không tìm thấy người dùng');
        return;
      }

      final favorites = List<String>.from(buyerData.favoriteStoreIds);
      final isFavorite = favorites.contains(storeId);

      if (isFavorite) {
        favorites.remove(storeId);
      } else {
        favorites.add(storeId);
      }

      await _buyerRepository.updateBuyer(user.uid, {'favoriteStoreIds': favorites});

      favoriteStoreId.assignAll(favorites);

      if (isFavorite) {
        favoriteStores.removeWhere((store) => store.storeId == storeId);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getFavoriteStores() async {
    final user = auth.currentUser;
    if (user == null) {
      Get.snackbar('Lỗi', 'Bạn chưa đăng nhập');
      return;
    }

    try {
      isLoading.value = true;

      final buyerData = await _buyerRepository.getBuyerById(user.uid);
      if (buyerData == null) {
        Get.snackbar('Lỗi', 'Không tìm thấy người dùng');
        return;
      }

      final ids = buyerData.favoriteStoreIds;
      favoriteStoreId.assignAll(ids);

      if (ids.isEmpty) {
        favoriteStores.clear();
        return;
      }

      final snapshot = await firestore.collection('stores').where(FieldPath.documentId, whereIn: ids).get();

      final stores =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return StoreModel.fromJson(data);
          }).toList();

      favoriteStores.assignAll(stores);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải cửa hàng yêu thích: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
