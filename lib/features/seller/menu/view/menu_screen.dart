import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/menu.dart';
import 'package:agrimarket/features/seller/menu/viewmodel/menu_screen_vm.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerMenuScreen extends StatelessWidget {
  SellerMenuScreen({super.key});

  final SellerMenuVm menuVm = Get.find<SellerMenuVm>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Quản lý Menu', style: AppTextStyles.headline),
        centerTitle: true,
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            onPressed: () => _showCreateGroupDialog(context),
            icon: const Icon(Icons.add, color: AppColors.primary),
          ),
        ],
      ),
      body: Obx(() {
        if (menuVm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (menuVm.menuModel.value == null) {
          return const Center(child: Text('Không tìm thấy menu.'));
        }

        final groups = menuVm.menuModel.value!.groups;

        return RefreshIndicator(
          onRefresh: () async => await menuVm.fetchMenu(),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final group = groups[index];
              return _buildMenuGroupItem(
                group: group,
                index: index,
                context: context,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildMenuGroupItem({
    required MenuGroup group,
    required int index,
    required BuildContext context,
  }) {
    final products = menuVm.getProductsForGroup(index);

    return ExpansionTileCard(
      elevation: 2,
      baseColor: const Color.fromARGB(255, 174, 198, 159),
      expandedColor: AppColors.background,
      borderRadius: BorderRadius.circular(12),

      title: Text(
        group.title,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle:
          group.description.isNotEmpty
              ? Text(
                group.description,
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              )
              : null,
      initiallyExpanded: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _showAddProductsDialog(context, index),
                    icon: Icon(Icons.add, size: 15),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppColors.primary,
                          size: 15,
                        ),
                        onPressed:
                            () => _showEditGroupDialog(context, index, group),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 15,
                        ),
                        onPressed: () {
                          Get.defaultDialog(
                            title: 'Xác nhận xoá menu',
                            titleStyle: AppTextStyles.headline,
                            content: Text(
                              'Bạn có chắc muốn xoá menu',
                              textAlign: TextAlign.center,
                            ),
                            textConfirm: 'Xóa',
                            textCancel: 'Hủy',
                            confirmTextColor: Colors.white,
                            cancelTextColor: AppColors.textPrimary,
                            buttonColor: AppColors.error,
                            onConfirm: () {
                              menuVm.deleteMenuGroup(index);
                              Get.back();
                            },
                            onCancel: () {},
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, productIndex) {
                  final product = products[productIndex];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.imageUrl,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(product.name, style: AppTextStyles.body),
                        ),
                        IconButton(
                          onPressed: () {
                            Get.defaultDialog(
                              title: 'Xác nhận xoá sản phẩm',
                              titleStyle: AppTextStyles.headline,
                              content: Text(
                                'Bạn có chắc muốn xoá sản phẩm này khỏi menu',
                                textAlign: TextAlign.center,
                              ),
                              textConfirm: 'Xóa',
                              textCancel: 'Hủy',
                              confirmTextColor: Colors.white,
                              cancelTextColor: AppColors.textPrimary,
                              buttonColor: AppColors.error,
                              onConfirm: () {
                                menuVm.removeProductFromGroup(
                                  index,
                                  product.id,
                                );
                                Get.back();
                              },
                              onCancel: () {},
                            );
                          },
                          icon: Icon(
                            Icons.delete,
                            size: 14,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.background,
            title: Text(
              'Tạo nhóm Menu',
              textAlign: TextAlign.center,
              style: AppTextStyles.headline,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
                    hintText: 'Nhập tiêu đề nhóm menu',
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    hintText: 'Nhập mô tả (tùy chọn)',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Hủy',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    menuVm.addMenuGroup(
                      titleController.text.trim(),
                      descriptionController.text.trim(),
                    );
                    Get.back();
                  } else {
                    Get.snackbar(
                      'Lỗi',
                      'Vui lòng nhập tiêu đề',
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 3),
                    );
                  }
                },
                child: const Text(
                  'Tạo',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditGroupDialog(BuildContext context, int index, MenuGroup group) {
    final titleController = TextEditingController(text: group.title);
    final descriptionController = TextEditingController(
      text: group.description,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.background,
            title: Text('Chỉnh sửa nhóm menu', style: AppTextStyles.headline),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
                    hintText: 'Nhập tiêu đề nhóm menu',
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    hintText: 'Nhập mô tả (tùy chọn)',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Hủy',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    menuVm.updateMenuGroup(
                      index,
                      titleController.text.trim(),
                      descriptionController.text.trim(),
                    );
                    Get.back();
                  } else {
                    Get.snackbar(
                      'Lỗi',
                      'Vui lòng nhập tiêu đề',
                      snackPosition: SnackPosition.TOP,
                    );
                  }
                },
                child: const Text(
                  'Lưu',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _showAddProductsDialog(BuildContext context, int groupIndex) {
    final selectedProductIds = <String>[].obs;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.background,
            title: Text(
              'Thêm sản phẩm vào nhóm',
              style: AppTextStyles.headline,
            ),
            content: Obx(() {
              final availableProducts = menuVm.productVm!.allProducts;
              if (availableProducts.isEmpty) {
                return const Text('Chưa có sản phẩm nào trong cửa hàng.');
              }

              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableProducts.length,
                  itemBuilder: (context, index) {
                    final product = availableProducts[index];
                    return Obx(
                      () => CheckboxListTile(
                        title: Text(product.name, style: AppTextStyles.body),
                        value: selectedProductIds.contains(product.id),
                        onChanged: (value) {
                          if (value == true) {
                            selectedProductIds.add(product.id);
                          } else {
                            selectedProductIds.remove(product.id);
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            }),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Hủy',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (selectedProductIds.isNotEmpty) {
                    menuVm.addProductsToGroup(groupIndex, selectedProductIds);
                    Get.back();
                  } else {
                    Get.snackbar(
                      'Lỗi',
                      'Vui lòng chọn ít nhất một sản phẩm',
                      snackPosition: SnackPosition.TOP,
                    );
                  }
                },
                child: const Text(
                  'Thêm',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }
}
