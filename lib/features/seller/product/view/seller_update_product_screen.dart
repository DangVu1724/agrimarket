import 'dart:io';

import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/custom_button.dart';
import 'package:agrimarket/core/widgets/custom_text_form_field.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/services/image_service.dart';
import 'package:agrimarket/features/seller/product/viewmodel/seller_product_screen_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerUpdateProductScreen extends StatelessWidget {
  final ProductModel product;
  SellerUpdateProductScreen({super.key, required this.product});

  final SellerProductVm productVm = Get.find<SellerProductVm>();
  final ImageService _imageService = ImageService();

  @override
  Widget build(BuildContntext) {
    productVm.initUpdateProduct(product);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Cập nhật sản phẩm", style: AppTextStyles.headline),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: productVm.productKey,
            child: Column(
              children: [
                CustomTextFormField(
                  label: 'Tên sản phẩm',
                  hintText: 'Nhập tên sản phẩm',
                  controller: productVm.nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên sản phẩm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  label: 'Mô tả sản phẩm',
                  hintText: 'Nhập mô tả sản phẩm',
                  controller: productVm.descController,
                  maxLine: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả sản phẩm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  label: 'Giá',
                  hintText: 'Nhập giá sản phẩm',
                  controller: productVm.priceController,
                  keyboard: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá sản phẩm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  label: 'Số lượng',
                  hintText: 'Nhập số lượng sản phẩm',
                  controller: productVm.quantityController,
                  keyboard: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số lượng sản phẩm';
                    }
                    return null;
                  },
                ),

                CustomTextFormField(
                  label: 'Đơn vị',
                  hintText: 'Nhập đơn vị sản phẩm',
                  controller: productVm.unitController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập đơn vị sản phẩm';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),
                Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danh mục',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      productVm.categories.isEmpty
                          ? const CircularProgressIndicator()
                          : DropdownButtonFormField<String>(
                            value: productVm.categoryDefault.value,
                            items:
                                productVm.categories
                                    .map(
                                      (category) => DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(category),
                                      ),
                                    )
                                    .toList(),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary,
                            ),
                            isExpanded: true,
                            menuMaxHeight: 300,
                            onChanged: (value) {
                              productVm.categoryDefault.value = value!;
                              productVm.update();
                            },
                          ),
                      const SizedBox(height: 15),

                      Builder(
                        builder: (context) {
                          return Obx(() {
                            final file = productVm.imageProduct.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              productVm.imageProduct.value =
                                                  null;
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                    : productVm.currentImageUrl.value.isNotEmpty
                                    ? Stack(
                                      children: [
                                        Image.network(
                                          productVm.currentImageUrl.value,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    height: 100,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      size: 50,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              productVm.currentImageUrl.value =
                                                  '';
                                            },
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
                                      child: const Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        final file =
                                            await _imageService.pickImage();
                                        if (file != null) {
                                          productVm.imageProduct.value = file;
                                        }
                                      },
                                      child: const Text('Chọn từ thư viện'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final file = await _imageService
                                            .pickImage(fromCamera: true);
                                        if (file != null) {
                                          productVm.imageProduct.value = file;
                                        }
                                      },
                                      child: const Text('Chụp ảnh'),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomButton(
                        text: 'Cập nhật sản phẩm',
                        onPressed: () {
                          if (productVm.productKey.currentState!.validate() &&
                              productVm.categories.isNotEmpty 
                              ) {
                            productVm.updateProduct(product.id);
                          } else {
                            Get.snackbar('Lỗi', 'Vui lòng cập nhật sản phẩm.');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
