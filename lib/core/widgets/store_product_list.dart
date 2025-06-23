import 'dart:math';

import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/store_service.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/buyer_home_vm.dart';
import 'package:agrimarket/features/buyer/store/viewmodel/store_detail_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StoreProductList extends StatelessWidget {
  final String storeId;

  StoreProductList({required this.storeId});

  final BuyerHomeScreenVm productController = Get.put(BuyerHomeScreenVm());
  final StoreService storeService = StoreService();
  final StoreDetailVm storeDetailVm = Get.find<StoreDetailVm>();

  @override
  Widget build(BuildContext context) {
    productController.loadProductsByStore(storeId);
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return FutureBuilder<StoreModel>(
      future: storeService.fetchStoresbyID(storeId),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Lỗi khi tải thông tin cửa hàng'));
        }

        final store = snapshot.data!;

        return Obx(() {
          final products = productController.products;

          if (products.isEmpty) {
            return const Center(child: Text('Không có sản phẩm'));
          }

          return Container(
            height: 150,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (_, index) {
                final product = products[index];

                return FutureBuilder<ProductPromotionModel?>(
                  future:
                      product.promotion != null
                          ? storeDetailVm.getDiscountInfo(product.promotion!)
                          : Future.value(null),
                  builder: (context, discountSnapshot) {
                    final discount = discountSnapshot.data;
                    final hasValidDiscount = discount?.isValid ?? false;


                    double finalPrice = product.price;
    String priceText = '${currencyFormatter.format(product.price)} /${product.unit}';

    if (hasValidDiscount) {
      // Tính toán giá sau giảm
      if (discount!.discountType == 'percent') {
        finalPrice = max(0, product.price * (1 - discount.discountValue / 100));
      } else if (discount.discountType == 'fixed') {
        finalPrice = max(0, product.price - discount.discountValue);
      }

      priceText = '''
        ${currencyFormatter.format(product.price)} /${product.unit}
        ${currencyFormatter.format(finalPrice)} /${product.unit} (Giảm ${discount.discountType == 'percent' 
          ? '${discount.discountValue}%' 
          : '${currencyFormatter.format(discount.discountValue)}'})
        Áp dụng đến: ${DateFormat('dd/MM/yyyy').format(discount.endDate)}
      ''';
    }

                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.store, arguments: store);
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child:
                                  product.imageUrl.isNotEmpty
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 80,
                                        ),
                                      )
                                      : const Icon(Icons.image, size: 40),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (hasValidDiscount) ...[
                                    Text(
                                      currencyFormatter.format(product.price),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    Text(
                                      currencyFormatter.format(finalPrice),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      currencyFormatter.format(product.price),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        });
      },
    );
  }
}
