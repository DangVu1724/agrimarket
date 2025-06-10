import 'package:agrimarket/data/models/buyer.dart';
import 'package:agrimarket/data/providers/firestore_provider.dart';

class AddressRepository {
  final FirestoreProvider _firestoreProvider = FirestoreProvider();

  Future<BuyerModel?> getBuyer(String uid) async {
    return await _firestoreProvider.getBuyerById(uid);
  }

  Future<void> saveBuyer(BuyerModel buyer) async {
    await _firestoreProvider.createBuyer(buyer);
  }

  Future<void> addAddress(String uid, Address newAddress) async {
    BuyerModel? buyer = await getBuyer(uid);
    if (buyer == null) {
      buyer = BuyerModel(
        uid: uid,
        favoriteStoreIds: [],
        addresses: [],
        reviews: [],
        orderIds: [],
      );
    }
    final updatedAddresses = [...buyer.addresses, newAddress];
    final updatedBuyer = buyer.copyWith(addresses: updatedAddresses);
    await saveBuyer(updatedBuyer);
  }

  Future<void> updateAddress(
    String uid,
    int index,
    Address updatedAddress,
  ) async {
    BuyerModel? buyer = await getBuyer(uid);
    if (buyer == null) return;
    final updatedAddresses = List<Address>.from(buyer.addresses);
    if (index < 0 || index >= updatedAddresses.length) return;
    updatedAddresses[index] = updatedAddress;
    final updatedBuyer = buyer.copyWith(addresses: updatedAddresses);
    await saveBuyer(updatedBuyer);
  }

  Future<void> setDefaultAddress(String uid, int index) async {
    BuyerModel? buyer = await getBuyer(uid);
    if (buyer == null) return;
    final updatedAddresses =
        buyer.addresses.asMap().entries.map((entry) {
          int i = entry.key;
          Address address = entry.value;
          return address.copyWith(isDefault: i == index);
        }).toList();
    final updatedBuyer = buyer.copyWith(addresses: updatedAddresses);
    await saveBuyer(updatedBuyer);
  }

  Future<void> deleteAddress(String uid, int indexToDelete) async {
    BuyerModel? buyer = await getBuyer(uid);
    if (buyer == null) return;

    final updatedAddresses = List<Address>.from(buyer.addresses);
    if (indexToDelete < 0 || indexToDelete >= updatedAddresses.length) {
      throw Exception('Không tìm thấy địa chỉ để xóa');
    }

    bool wasDefault = updatedAddresses[indexToDelete].isDefault;

    updatedAddresses.removeAt(indexToDelete);

    // Nếu xóa địa chỉ mặc định thì set địa chỉ đầu tiên làm mặc định nếu còn địa chỉ
    if (wasDefault && updatedAddresses.isNotEmpty) {
      updatedAddresses[0] = updatedAddresses[0].copyWith(isDefault: true);
      for (int i = 1; i < updatedAddresses.length; i++) {
        updatedAddresses[i] = updatedAddresses[i].copyWith(isDefault: false);
      }
    }

    final updatedBuyer = buyer.copyWith(addresses: updatedAddresses);
    await saveBuyer(updatedBuyer);
  }
}
