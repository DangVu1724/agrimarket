import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SearchItem extends StatelessWidget {
  final StoreModel store;
  final List<ProductModel> products;
  final String? distance;
  final int? totalTime;

  const SearchItem({
    super.key,
    required this.store,
    required this.products,
    required this.distance,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 167, 255, 193),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed(AppRoutes.store, arguments: store);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====== Thông tin shop ======
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      store.storeImageUrl ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.store, size: 40),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              store.name,
                              style: AppTextStyles.headline.copyWith(fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (store.rating != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(store.rating.toString(), style: AppTextStyles.body.copyWith(fontSize: 12)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),

                        if (distance != null) ...[
                          Row(
                            children: [
                              Text(
                                "$distance ~ ",
                                style: AppTextStyles.body.copyWith(fontSize: 12, color: Colors.black),
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  store.storeLocation.address,
                                  style: AppTextStyles.body.copyWith(fontSize: 12, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ====== Danh sách sản phẩm phù hợp ======
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length.clamp(0, 5), // Giới hạn 5 sản phẩm
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, productIndex) {
                    final product = products[productIndex];
                    return InkWell(
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.buyerProductDetail,
                          arguments: {'store': store.toJson(), 'product': product.toJson()},
                        );
                      },
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                product.imageUrl,
                                width: 100,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 40),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              '${currencyFormatter.format(product.displayPrice)} /${product.unit}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
