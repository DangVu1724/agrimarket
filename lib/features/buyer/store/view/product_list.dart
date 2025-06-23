import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/data/models/menu.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/features/buyer/store/viewmodel/cart_vm.dart';
import 'package:agrimarket/features/buyer/store/viewmodel/store_detail_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class productListWidget extends StatelessWidget {
  const productListWidget({
    super.key,
    required this.group,
    required this.vm,
    required this.store,
  });

  final MenuGroup group;
  final StoreDetailVm vm;
  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    final products = vm.filterProductsByIds(group.productIds);
    final CartVm cartVm = Get.find<CartVm>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (products.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final product = products[index];
          return FutureBuilder<ProductPromotionModel?>(
            future:
                product.promotion != null
                    ? vm.getDiscountInfo(product.promotion!)
                    : Future.value(null),
            builder: (context, snapshot) {
              final discount = snapshot.data;
              final hasValidDiscount = discount?.isValid ?? false;

              return GestureDetector(
                onTap: () {
                  // Đảm bảo các model có phương thức toJson()
                  Get.toNamed(
                    AppRoutes.buyerProductDetail,
                    arguments: {
                      'store': store.toJson(),
                      'product': product.toJson(),
                      'discount': discount?.toJson(),
                    },
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Opacity(
                    opacity: store.isOpened ? 1.0 : 0.5,
                    child: ListTile(
                      enabled: store.isOpened,
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl,
                          width: 80,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.image, size: 60),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[300],
                              width: 80,
                              height: 70,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.promotion != null &&
                              hasValidDiscount) ...[
                            Text(
                              '${currencyFormatter.format(product.price)} /${product.unit}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),

                            const SizedBox(height: 4),
                            Text(
                              discount?.discountType == "percent"
                                  ? currencyFormatter.format(
                                    product.price -
                                        (product.price *
                                                discount!.discountValue) /
                                            100,
                                  )
                                  : currencyFormatter.format(
                                    product.price - discount!.discountValue,
                                  ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else ...[
                            Text(
                              '${currencyFormatter.format(product.price)} /${product.unit}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          if (product.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                      trailing: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                          icon: const Icon(Icons.add, color: AppColors.primary),
                          onPressed:
                              store.isOpened
                                  ? () {
                                    cartVm.addItem(product: product, store: store, itemCount: 1);
                                  }
                                  : null,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        childCount: products.isEmpty ? 1 : products.length,
        addAutomaticKeepAlives: true,
      ),
    );
  }
}
