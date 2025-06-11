import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/features/seller/product/viewmodel/seller_product_screen_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const SellerProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final SellerProductVm productVm = Get.find<SellerProductVm>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(product.name, style: AppTextStyles.headline),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(AppRoutes.sellerUpdateProduct,arguments: product);
            },
            icon: Icon(Icons.edit, size: 16),
          ),
        ],
      ),
      // body: Obx( () {
      //   return
      body: RefreshIndicator(
        onRefresh: () async {
          await productVm.fetchProducts();
        },
        child: SingleChildScrollView(
          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsetsGeometry.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.headline.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Giá: ${product.price} VND / ${product.unit}',
                      style: AppTextStyles.body.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text('Mô tả: ${product.description}', style: AppTextStyles.body),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
