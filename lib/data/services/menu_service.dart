import 'package:agrimarket/data/models/menu.dart';
import 'package:agrimarket/data/models/product.dart';

class MenuService {
  MenuModel addMenuGroup(
    MenuModel? currentMenu,
    String storeId,
    String title,
    String description,
  ) {
    final newGroup = MenuGroup(
      title: title,
      description: description,
      productIds: [],
    );

    final updatedGroups = [...(currentMenu?.groups ?? <MenuGroup>[]), newGroup];

    return currentMenu?.copyWith(groups: updatedGroups) ??
        MenuModel(storeId: storeId, groups: [newGroup]);
  }

  MenuModel updateMenuGroup(
    MenuModel menu,
    int index,
    String title,
    String description,
  ) {
    if (index >= menu.groups.length) return menu;

    final updatedGroup = MenuGroup(
      title: title,
      description: description,
      productIds: menu.groups[index].productIds,
    );

    final updatedGroups = [...menu.groups];
    updatedGroups[index] = updatedGroup;
    return menu.copyWith(groups: updatedGroups);
  }

  MenuModel deleteMenuGroup(MenuModel menu, int index) {
    if (index >= menu.groups.length) return menu;

    final updatedGroups = [...menu.groups]..removeAt(index);
    return menu.copyWith(groups: updatedGroups);
  }

  MenuModel addProductsToGroup(
    MenuModel menu,
    int groupIndex,
    List<String> productIds,
  ) {
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

  List<ProductModel> getProductsForGroup(
    MenuGroup group,
    List<ProductModel> allProducts,
  ) {
    return allProducts
        .where((product) => group.productIds.contains(product.id))
        .toList();
  }
}
