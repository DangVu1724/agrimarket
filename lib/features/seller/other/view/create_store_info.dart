import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/features/seller/other/viewmodel/create_store_vm.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class CreateStoreInfoScreen extends StatelessWidget {
  final CreateStoreViewModel vm = Get.find<CreateStoreViewModel>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tạo cửa hàng - Bước 1',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () =>
              vm.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin cửa hàng',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: vm.nameController,
                            decoration: const InputDecoration(
                              labelText: 'Tên cửa hàng',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Vui lòng nhập tên cửa hàng'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: vm.descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Mô tả cửa hàng',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Vui lòng nhập mô tả'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Danh mục sản phẩm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children:
                                vm.availableCategories.map((category) {
                                  return Obx(
                                    () => FilterChip(
                                      label: Text(
                                        category,
                                        style: TextStyle(
                                          color:
                                              vm.categories.contains(category)
                                                  ? Colors.white
                                                  : Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      selected: vm.categories.contains(
                                        category,
                                      ),
                                      checkmarkColor: AppColors.background,
                                      onSelected:
                                          (selected) =>
                                              vm.toggleCategory(category),
                                      selectedColor: AppColors.primary,
                                      disabledColor: AppColors.background,
                                      backgroundColor: AppColors.background,
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chứng chỉ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildCertificateSection(
                            context,
                            title: 'Chứng chỉ kinh doanh',
                            file: vm.businessLicenseFile.value,
                            onPickGallery:
                                () => vm.pickImage(imageType: 'license'),
                            onPickCamera:
                                () => vm.pickImage(
                                  imageType: 'license',
                                  fromCamera: true,
                                ),
                            onClear: () => vm.clearImage('license'),
                          ),
                          const SizedBox(height: 16),
                          _buildCertificateSection(
                            context,
                            title: 'Chứng chỉ an toàn thực phẩm',
                            file: vm.foodSafetyCertificateFile.value,
                            onPickGallery:
                                () => vm.pickImage(imageType: 'food'),
                            onPickCamera:
                                () => vm.pickImage(
                                  imageType: 'food',
                                  fromCamera: true,
                                ),
                            onClear: () => vm.clearImage('food'),
                          ),
                          const SizedBox(height: 24),
                          _buildCertificateSection(
                            context,
                            title: 'Ảnh cửa hàng',
                            file: vm.storeImageFile.value,
                            onPickGallery:
                                () => vm.pickImage(imageType: 'store'),
                            onPickCamera:
                                () => vm.pickImage(
                                  imageType: 'store',
                                  fromCamera: true,
                                ),
                            onClear: () => vm.clearImage('store'),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate() &&
                                  vm.categories.isNotEmpty &&
                                  vm.businessLicenseFile.value != null &&
                                  vm.foodSafetyCertificateFile.value != null) {
                                Get.toNamed(AppRoutes.createStoreAddress);
                              } else {
                                Get.snackbar(
                                  'Lỗi',
                                  'Vui lòng điền đầy đủ thông tin, chọn danh mục và tải lên cả hai chứng chỉ',
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text(
                              'Tiếp tục',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildCertificateSection(
    BuildContext context, {
    required String title,
    required XFile? file,
    required VoidCallback onPickGallery,
    required VoidCallback onPickCamera,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        file != null
            ? Stack(
              children: [
                Image.file(
                  File(file.path),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onClear,
                  ),
                ),
              ],
            )
            : Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: onPickGallery,
              child: const Text('Chọn từ thư viện'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onPickCamera,
              child: const Text('Chụp ảnh'),
            ),
          ],
        ),
      ],
    );
  }
}
