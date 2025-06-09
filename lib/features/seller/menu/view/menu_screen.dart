import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/menu.dart';
import 'package:agrimarket/features/seller/menu/viewmodel/menu_screen_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerMenuScreen extends StatelessWidget {
  SellerMenuScreen({super.key});

  final SellerMenuVm menuVm = Get.find<SellerMenuVm>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Quản lý Menu', style: AppTextStyles.headline),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (menuVm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (menuVm.menuModel.value == null) {
          return const Center(child: Text("Không tìm thấy menu."));
        }

        final groups = menuVm.menuModel.value!.groups;

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: groups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final group = groups[index];
            return _buildMenuGroupItem(
              group: group,
              index: index,
              onEdit: () => _showEditGroupDialog(context, index, group),
              onDelete: () => menuVm.deleteMenuGroup(index),
              onAddProducts: () => _showAddProductsDialog(context, index),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Thêm nhóm menu",
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
        onPressed: () => _showCreateGroupDialog(context),
      ),
    );
  }

  Widget _buildMenuGroupItem({
    required MenuGroup group,
    required int index,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onAddProducts,
  }) {
    final products = menuVm.getProductsForGroup(index);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  group.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          if (group.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              group.description,
              style: AppTextStyles.body.copyWith(color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Sản phẩm:',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
          if (products.isEmpty)
            const Text('Chưa có sản phẩm', style: TextStyle(color: Colors.grey))
          else
            Column(
              children:
                  products
                      .map(
                        (product) => Padding(
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: AppTextStyles.body,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onAddProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thêm sản phẩm'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Tạo nhóm menu'),
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            print('Nút Tạo được nhấn'); 
            try {
              if (titleController.text.trim().isNotEmpty) {
                print('Tiêu đề: ${titleController.text}');
                menuVm.addMenuGroup(
                  titleController.text.trim(),
                  descriptionController.text.trim(),
                );
                Navigator.pop(context);
              } else {
                Get.snackbar(
                  'Lỗi',
                  'Vui lòng nhập tiêu đề',
                  snackPosition: SnackPosition.TOP,
                  duration: const Duration(seconds: 3),
                );
              }
            } catch (e) {
              print('Lỗi khi tạo nhóm menu: $e');
              Get.snackbar(
                'Lỗi',
                'Không thể tạo nhóm menu: $e',
                snackPosition: SnackPosition.TOP,
              );
            }
          },
          child: const Text('Tạo'),
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
            title: const Text('Chỉnh sửa nhóm menu'),
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    menuVm.updateMenuGroup(
                      index,
                      titleController.text.trim(),
                      descriptionController.text.trim(),
                    );
                    Navigator.pop(context);
                  } else {
                    Get.snackbar('Lỗi', 'Vui lòng nhập tiêu đề');
                  }
                },
                child: const Text('Lưu'),
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
            title: const Text('Thêm sản phẩm vào nhóm'),
            content: Obx(() {
              final availableProducts = menuVm.productVm.allProducts;
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
                    return CheckboxListTile(
                      title: Text(product.name),
                      value: selectedProductIds.contains(product.id),
                      onChanged: (value) {
                        if (value == true) {
                          selectedProductIds.add(product.id);
                        } else {
                          selectedProductIds.remove(product.id);
                        }
                      },
                    );
                  },
                ),
              );
            }),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedProductIds.isNotEmpty) {
                    menuVm.addProductsToGroup(groupIndex, selectedProductIds);
                    Navigator.pop(context);
                  } else {
                    Get.snackbar('Lỗi', 'Vui lòng chọn ít nhất một sản phẩm');
                  }
                },
                child: const Text('Thêm'),
              ),
            ],
          ),
    );
  }
}
