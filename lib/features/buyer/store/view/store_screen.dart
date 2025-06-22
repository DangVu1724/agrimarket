import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/core/widgets/skeleton_loader.dart';
import 'package:agrimarket/data/models/menu.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/store/viewmodel/store_detail_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sliver_tools/sliver_tools.dart';

class StoreScreen extends StatelessWidget {
  final StoreModel store;

  const StoreScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final StoreDetailVm vm = Get.find<StoreDetailVm>();
    final BuyerVm buyerVm = Get.find<BuyerVm>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.loadStoreData(store.storeId);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: () => vm.refreshStoreData(store.storeId),
        child: Obx(() {
          final menu = vm.getMenuForStore(store.storeId);
          final isLoading = vm.isLoading.value;

          if (isLoading && menu == null) {
            return const SkeletonLoader();
          }

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.primary,
                pinned: true,
                expandedHeight: 150,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                actions: [
                  IconButton(
                    icon: Obx(() {
                      final isFavorite = buyerVm.favoriteStoreId.contains(
                        store.storeId,
                      );
                      return Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      );
                    }),
                    onPressed: () {
                      buyerVm.toggleFavoriteStore(store.storeId);
                    },
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.store_mall_directory,
                      color: Colors.white,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        store.storeImageUrl ??
                            'https://images.unsplash.com/photo-1582407947304-fd86f028f716?auto=format&fit=crop&w=800&q=80',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Container(color: Colors.grey[300]),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    store.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              store.address,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            store.isOpened ? 'Mở cửa' : 'Đóng cửa',
                            style: TextStyle(
                              fontSize: 14,
                              color: store.isOpened ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              if (menu == null)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('Không có menu cho cửa hàng này.'),
                    ),
                  ),
                )
              else
                MultiSliver(
                  children:
                      menu.groups
                          .map(
                            (group) => SliverStickyHeader(
                              header: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  group.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              sliver: _buildProductList(group, vm, store),
                            ),
                          )
                          .toList(),
                ),
            ],
          );
        }),
      ),
    );
  }

  SliverList _buildProductList(
    MenuGroup group,
    StoreDetailVm vm,
    StoreModel store,
  ) {
    final products = vm.filterProductsByIds(group.productIds);
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
              child: Center(child: Text('Không có sản phẩm trong nhóm này.')),
            );
          }

          final product = products[index];
          return FutureBuilder<Map<String, dynamic>?>(
            future:
                product.promotion != null
                    ? vm.getDiscountInfo(product.promotion!)
                    : Future.value(null),
            builder: (context, snapshot) {
              final discountInfo =
                  snapshot.data ??
                  (product.promotion != null
                      ? vm.getPromotionForId(product.promotion!)
                      : null);
              String? discountType;
              dynamic discountValue;
              if (discountInfo != null) {
                discountType = discountInfo['discountType'];
                discountValue = discountInfo['discountValue'];
              }

              return GestureDetector(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.buyerProductDetail,
                    arguments: {'store': store, 'product': product},
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
                          if (product.promotion != null) ...[
                            Text(
                              '${currencyFormatter.format(product.price)} /${product.unit}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            if (discountInfo != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                discountType == "percent"
                                    ? currencyFormatter.format(
                                      product.price -
                                          (product.price * discountValue) / 100,
                                    )
                                    : currencyFormatter.format(
                                      product.price - discountValue,
                                    ),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                                    Get.snackbar(
                                      'Thêm vào giỏ hàng',
                                      '${product.name} đã được thêm vào giỏ hàng.',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
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
