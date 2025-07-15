import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchVm searchVm = Get.find<SearchVm>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchVm.searchController.clear();
      searchVm.searchText.value = '';
      searchVm.searchResults.clear();
    });

    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tìm kiếm', style: AppTextStyles.headline),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ô tìm kiếm
            TextField(
              controller: searchVm.searchController,
              onSubmitted: (value) => searchVm.searchProducts(value),
              decoration: InputDecoration(
                hintText: 'Bạn muốn mua gì?',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() {
                  return searchVm.searchText.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchVm.searchController.clear();
                          searchVm.searchResults.clear();
                          searchVm.searchText.value = '';
                        },
                      )
                      : const SizedBox.shrink();
                }),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Kết quả hoặc lịch sử
            Expanded(
              child: Obx(() {
                final results = searchVm.searchResults;
                final history = searchVm.history;
                final keyword = searchVm.searchText.value;
                final isSearching = searchVm.isSearching.value;

                if (isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (results.isNotEmpty) {
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      final product = result.product;
                      final store = result.store;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.buyerProductDetail,
                              arguments: {'store': store!.toJson(), 'product': product.toJson()},
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hình ảnh sản phẩm
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 60),
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Thông tin sản phẩm
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: AppTextStyles.headline.copyWith(fontSize: 16),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        store?.name ?? '',
                                        style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 4),
                                      if (product.isOnSale) ...[
                                        Row(
                                          children: [
                                            Text(
                                              '${currencyFormatter.format(product.price)} /${product.unit}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              '${currencyFormatter.format(product.displayPrice)} /${product.unit}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.red.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (product.promotionTimeLeft.isNotEmpty)
                                          Text(
                                            product.promotionTimeLeft,
                                            style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (keyword.isNotEmpty && results.isEmpty && !isSearching && searchVm.hasSearched.value) {
                  return Column(
                    children: [
                      _buildCategoryList(),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Không có sản phẩm bạn muốn tìm',
                          style: AppTextStyles.headline.copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                } else if (history.isNotEmpty && keyword.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryList(),
                      const SizedBox(height: 20),
                      const Text('Tìm kiếm gần đây', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final keyword = history[index];
                            return ListTile(
                              leading: const Icon(Icons.history),
                              title: Text(keyword),
                              onTap: () {
                                searchVm.searchController.text = keyword;
                                searchVm.searchProducts(keyword);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildCategoryList(),
                      const SizedBox(height: 20),
                      const Center(child: Text('Hãy nhập từ khoá để tìm kiếm')),
                    ],
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final items = [
      'Trái cây',
      'Rau củ',
      'Thực phẩm chế biến',
      'Ngũ cốc - Hạt',
      'Sữa & Trứng',
      'Thịt',
      'Thuỷ hải sản',
      'Gạo',
    ];
    final List<String> imageCategory = [
      "assets/images/fruit.png",
      "assets/images/vegetable.png",
      "assets/images/cooked_food.png",
      "assets/images/grain.png",
      "assets/images/milkAegg.png",
      "assets/images/meat.png",
      "assets/images/sea_food.png",
      "assets/images/rice.png",
    ];

    return Wrap(
      runSpacing: 16,
      spacing: 16,
      alignment: WrapAlignment.center,
      children: List.generate(items.length, (index) {
        return GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.categoryStoreScreen, arguments: items[index]);
          },
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(imageCategory[index], fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 70,
                child: Text(
                  items[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
