import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/buyer/search/view/widgets/product_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SearchResultItem extends StatelessWidget {
  final dynamic result;
  const SearchResultItem({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    final product = result.product;
    final store = result.store;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Get.toNamed(AppRoutes.buyerProductDetail, arguments: {'store': store!.toJson(), 'product': product.toJson()});
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 1, child: ProductImage(imageUrl: product.imageUrl)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Text(
                product.name,
                style: AppTextStyles.headline.copyWith(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: Text(
                store?.name ?? '',
                style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            if (product.isOnSale) ...[
              Text(
                '${currencyFormatter.format(product.price)} /${product.unit}',
                style: const TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough),
              ),
              Text(
                '${currencyFormatter.format(product.displayPrice)} /${product.unit}',
                style: TextStyle(fontSize: 14, color: Colors.red.shade700, fontWeight: FontWeight.bold),
              ),
              if (product.promotionTimeLeft.isNotEmpty)
                Text(product.promotionTimeLeft, style: TextStyle(fontSize: 12, color: Colors.blue.shade600)),
            ] else
              Text(
                '${currencyFormatter.format(product.price)} /${product.unit}',
                style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange.shade400, size: 14),
                const SizedBox(width: 4),
                if (store.rating != null) ...[
                  Text(store.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
                ] else ...[
                  Text('4.0', style: const TextStyle(fontSize: 12)),
                ],
                const SizedBox(width: 8),
                Text('(${product.totalSold} đã bán)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
