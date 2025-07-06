import 'package:agrimarket/data/models/menu.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/repo/menu_repo.dart';

import 'package:agrimarket/data/services/menu_service.dart';
import 'package:agrimarket/features/seller/product/viewmodel/seller_product_screen_vm.dart';
import 'package:get/get.dart';

class SellerMenuVm extends GetxController {
  final MenuRepository _menuRepository = MenuRepository();
  final MenuService _menuService = MenuService();
  late final SellerProductVm productVm;
  final Rx<MenuModel?> menuModel = Rx<MenuModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeProductViewModel();
    ever(productVm.allProducts, (_) {
      if (productVm.storeModel != null && menuModel.value == null) {
        fetchMenu();
      }
    });
  }

  void _initializeProductViewModel() {
    try {
      productVm = Get.find<SellerProductVm>();
    } catch (e) {
      Get.put(SellerProductVm());
      productVm = Get.find<SellerProductVm>();
    }
  }

  Future<void> fetchMenu() async {
    if (productVm.storeModel == null) {
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin cửa hàng.');
      return;
    }

    try {
      isLoading.value = true;
      final menu = await _menuService.fetchMenu(
        productVm.storeModel!.storeId,
      );
      menuModel.value =
          menu ?? MenuModel(storeId: productVm.storeModel!.storeId, groups: []);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải menu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveMenu() async {
    if (menuModel.value == null) return;
    try {
      await _menuService.saveMenu(menuModel.value!);
    } catch (e) {
      return;
    }
  }

  void addMenuGroup(String title, String description) {
    if (productVm.storeModel == null) {
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin cửa hàng.');
      return;
    }
    menuModel.value = _menuService.addMenuGroup(
      menuModel.value,
      productVm.storeModel!.storeId,
      title,
      description,
    );
    saveMenu();
  }

  void updateMenuGroup(int index, String title, String description) {
    if (menuModel.value == null || index >= menuModel.value!.groups.length) {
      Get.snackbar('Lỗi', 'Nhóm menu không hợp lệ.');
      return;
    }
    menuModel.value = _menuService.updateMenuGroup(
      menuModel.value!,
      index,
      title,
      description,
    );
    saveMenu();
  }

  void deleteMenuGroup(int index) {
    if (menuModel.value == null || index >= menuModel.value!.groups.length) {
      Get.snackbar('Lỗi', 'Nhóm menu không hợp lệ.');
      return;
    }
    menuModel.value = _menuService.deleteMenuGroup(menuModel.value!, index);
    saveMenu();
  }

  void addProductsToGroup(int groupIndex, List<String> productIds) {
    if (menuModel.value == null ||
        groupIndex >= menuModel.value!.groups.length) {
      Get.snackbar('Lỗi', 'Nhóm menu không hợp lệ.');
      return;
    }
    menuModel.value = _menuService.addProductsToGroup(
      menuModel.value!,
      groupIndex,
      productIds,
    );
    saveMenu();
  }

  void removeProductFromGroup(int groupIndex, String productId) {
    if(menuModel.value == null || groupIndex>= menuModel.value!.groups.length){
      return;
    }

    menuModel.value = _menuService.removeProducts(menuModel.value!, groupIndex, productId);

    saveMenu();
  }

  List<ProductModel> getProductsForGroup(int groupIndex) {
    if (menuModel.value == null ||
        groupIndex >= menuModel.value!.groups.length) {
      return [];
    }
    return _menuService.getProductsForGroup(
      menuModel.value!.groups[groupIndex],
      productVm.allProducts,
    );
  }

}
