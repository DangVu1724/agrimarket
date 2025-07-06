import 'package:agrimarket/data/models/menu.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/repo/menu_repo.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class MenuService {
  final MenuRepository _menuRepository = MenuRepository();

  final Box _menuBox = Hive.box('menuCache');

  static const _cacheDuration = 10 * 60 * 1000; // 10 phút

  Future<MenuModel?> fetchMenu(String storeId) async {
    final menu = await _menuRepository.fetchMenu(storeId);
    return menu;
  }

  Future<void> saveMenu(MenuModel menu) async {
    await _menuRepository.saveMenu(menu);
  }

  MenuModel addMenuGroup(MenuModel? currentMenu, String storeId, String title, String description) {
    final newGroup = MenuGroup(title: title, description: description, productIds: []);

    final updatedGroups = [...(currentMenu?.groups ?? <MenuGroup>[]), newGroup];

    return currentMenu?.copyWith(groups: updatedGroups) ?? MenuModel(storeId: storeId, groups: [newGroup]);
  }

  MenuModel updateMenuGroup(MenuModel menu, int index, String title, String description) {
    if (index >= menu.groups.length) return menu;

    final updatedGroup = MenuGroup(title: title, description: description, productIds: menu.groups[index].productIds);

    final updatedGroups = [...menu.groups];
    updatedGroups[index] = updatedGroup;
    return menu.copyWith(groups: updatedGroups);
  }

  MenuModel deleteMenuGroup(MenuModel menu, int index) {
    if (index >= menu.groups.length) return menu;

    final updatedGroups = [...menu.groups]..removeAt(index);
    return menu.copyWith(groups: updatedGroups);
  }

  MenuModel addProductsToGroup(MenuModel menu, int groupIndex, List<String> productIds) {
    if (groupIndex >= menu.groups.length) return menu;

    final currentGroup = menu.groups[groupIndex];
    final updatedProductIds = [
      ...currentGroup.productIds,
      ...productIds.where((id) => !currentGroup.productIds.contains(id)),
    ];

    final updatedGroup = currentGroup.copyWith(productIds: updatedProductIds);
    final updatedGroups = [...menu.groups];
    updatedGroups[groupIndex] = updatedGroup;
    return menu.copyWith(groups: updatedGroups);
  }

  MenuModel removeProducts(MenuModel menu, int groupIndex, String productId) {
    if (groupIndex >= menu.groups.length) return menu;

    final currentGroup = menu.groups[groupIndex];
    final updatedProductIds = [...currentGroup.productIds]..remove(productId);

    final updatedGroup = currentGroup.copyWith(productIds: updatedProductIds);
    final updatedGroups = [...menu.groups];
    updatedGroups[groupIndex] = updatedGroup;
    return menu.copyWith(groups: updatedGroups);
  }

  List<ProductModel> getProductsForGroup(MenuGroup group, List<ProductModel> allProducts) {
    return allProducts.where((product) => group.productIds.contains(product.id)).toList();
  }

  Future<MenuModel?> getMenuForStore(String storeId) async {
    // Kiểm tra cache trước
    final cachedMenu = _menuBox.get('menu_$storeId');
    final cacheTimestamp = _menuBox.get('menu_${storeId}_timestamp');
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cachedMenu != null && cacheTimestamp != null && now - cacheTimestamp < _cacheDuration) {
      try {
        return MenuModel.fromJson(Map<String, dynamic>.from(cachedMenu));
      } catch (e) {
        _menuBox.delete('menu_$storeId');
        _menuBox.delete('menu_${storeId}_timestamp');
      }
    }

    // Lấy từ repository nếu không có cache hoặc cache hết hạn
    try {
      final menu = await _menuRepository.fetchMenu(storeId);
      if (menu != null) {
        // Lưu vào cache
        _menuBox.put('menu_$storeId', menu.toJson());
        _menuBox.put('menu_${storeId}_timestamp', now);
      }
      return menu;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải menu: $e', snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  // Xóa cache cho một store cụ thể
  void clearMenuCacheForStore(String storeId) {
    _menuBox.delete('menu_$storeId');
    _menuBox.delete('menu_${storeId}_timestamp');
  }

  // Xóa tất cả cache menu
  void clearAllMenuCache() {
    _menuBox.clear();
  }

  // Lấy menu từ cache (không gọi API)
  MenuModel? getMenuFromCache(String storeId) {
    final cachedMenu = _menuBox.get('menu_$storeId');
    if (cachedMenu != null) {
      try {
        return MenuModel.fromJson(Map<String, dynamic>.from(cachedMenu));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
