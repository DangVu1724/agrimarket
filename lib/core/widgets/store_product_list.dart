import 'package:agrimarket/features/buyer/home/viewmodel/buyer_home_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreProductList extends StatelessWidget {
  final String storeId;

  StoreProductList({required this.storeId});

  final BuyerHomeScreenVm productController = Get.put(BuyerHomeScreenVm());

  @override
  Widget build(BuildContext context) {
    productController.loadProductsByStore(storeId); 

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
            return Container(
              width: 120,
              margin: const EdgeInsets.only(right: 10),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(product.imageUrl, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 40),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${product.price} đ",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
