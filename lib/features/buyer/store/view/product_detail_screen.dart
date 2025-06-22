import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  final StoreModel store;
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (product.imageUrl.isNotEmpty)
              Image.network(product.imageUrl, fit: BoxFit.cover)
            else
              Container(color: Colors.grey.shade300),

            Container(color: Colors.black.withOpacity(0.4)),

            AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                product.name,
                style: AppTextStyles.headline.copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.headline.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  'Giá: ${currencyFormatter.format(product.price)} / ${product.unit}',
                  style: AppTextStyles.body.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mô tả: ${product.description}',
                  style: AppTextStyles.body.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cửa hàng: ${store.name}',
                  style: AppTextStyles.body.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
