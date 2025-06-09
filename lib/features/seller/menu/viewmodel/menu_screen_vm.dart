import 'package:agrimarket/data/models/menu.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/features/seller/product/viewmodel/seller_product_screen_vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SellerMenuVm extends GetxController {
late final SellerProductVm productVm;
  final Rx<MenuModel?> menuModel = Rx<MenuModel?>(null);
  final RxBool isLoading = false.obs;
  

  @override
  void onInit() {
    super.onInit();
    try {
      productVm = Get.find<SellerProductVm>();
      print('Tìm thấy SellerProductVm');
    } catch (e) {
      print('Lỗi: Không tìm thấy SellerProductVm, đăng ký mới');
      Get.put(SellerProductVm());
      productVm = Get.find<SellerProductVm>();
    }
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    print('bat dau');
    
    if (productVm.storeModel == null) {
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin cửa hàng.');
      return;
    }

    try {
      isLoading.value = true;
      final docSnapshot = await FirebaseFirestore.instance
    .collection('menus')
    .doc(productVm.storeModel!.storeId)
    .get();

if (docSnapshot.exists) {
  menuModel.value = MenuModel.fromJson(docSnapshot.data()!);
} else {
  menuModel.value = MenuModel(
    storeId: productVm.storeModel!.storeId,
    groups: [],
  );
}

    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải menu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveMenu() async {
    if (menuModel.value == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('menus')
          .doc(menuModel.value!.storeId)
          .set(menuModel.value!.toJson());
      Get.snackbar('Thành công', 'Đã lưu menu');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể lưu menu: $e');
    }
  }

  void addMenuGroup(String title, String description) {
  if (menuModel.value == null) {
    menuModel.value = MenuModel(
      storeId: productVm.storeModel?.storeId ?? '',
      groups: [],
    );
  }

  try {
    final newGroup = MenuGroup(
      title: title,
      description: description,
      productIds: [],
    );
    menuModel.value!.groups.add(newGroup);
    print('Thêm nhóm menu: $title');
    saveMenu();
    update();
  } catch (e) {
    Get.snackbar('Lỗi', 'Không thể thêm nhóm menu: $e');
    print('Lỗi khi thêm nhóm menu: $e');
  }
}

  void updateMenuGroup(int index, String title, String description) {
    if (menuModel.value == null || index >= menuModel.value!.groups.length) return;

    menuModel.value!.groups[index] = MenuGroup(
      title: title,
      description: description,
      productIds: menuModel.value!.groups[index].productIds,
    );
    saveMenu();
    update();
  }

  void deleteMenuGroup(int index) {
    if (menuModel.value == null || index >= menuModel.value!.groups.length) return;

    menuModel.value!.groups.removeAt(index);
    saveMenu();
    update();
  }

  void addProductsToGroup(int groupIndex, List<String> productIds) {
    if (menuModel.value == null || groupIndex >= menuModel.value!.groups.length) return;

    final currentProductIds = menuModel.value!.groups[groupIndex].productIds;
    currentProductIds.addAll(productIds.where((id) => !currentProductIds.contains(id)));
    saveMenu();
    update();
  }

  List<ProductModel> getProductsForGroup(int groupIndex) {
    if (menuModel.value == null || groupIndex >= menuModel.value!.groups.length) {
      return [];
    }

    final productIds = menuModel.value!.groups[groupIndex].productIds;
    return productVm.allProducts
        .where((product) => productIds.contains(product.id))
        .toList();
  }
}