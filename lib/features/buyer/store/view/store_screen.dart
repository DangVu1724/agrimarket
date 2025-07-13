import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/core/widgets/skeleton_loader.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/store/view/product_list.dart';
import 'package:agrimarket/features/buyer/cart/viewmodel/cart_vm.dart';
import 'package:agrimarket/features/buyer/store/viewmodel/store_detail_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sliver_tools/sliver_tools.dart';

class StoreScreen extends StatelessWidget {
  final StoreModel store;

  const StoreScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final StoreDetailVm vm = Get.find<StoreDetailVm>();
    final BuyerVm buyerVm = Get.find<BuyerVm>();
    final CartVm cartVm = Get.find<CartVm>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.loadStoreData(store.storeId);
      cartVm.loadCart();
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
                  onPressed: () {
                    if (Get.isSnackbarOpen) {
                      Get.closeCurrentSnackbar();
                    } else {
                      Get.back();
                    }
                  },
                ),
                actions: [
                  IconButton(
                    icon: Obx(() {
                      final isFavorite = buyerVm.favoriteStoreId.contains(store.storeId);
                      return Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      );
                    }),
                    onPressed: () {
                      buyerVm.toggleFavoriteStore(store.storeId);
                    },
                  ),

                  IconButton(onPressed: () {}, icon: const Icon(LucideIcons.messageCircle, color: Colors.white)),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        store.storeImageUrl ??
                            'https://images.unsplash.com/photo-1582407947304-fd86f028f716?auto=format&fit=crop&w=800&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.6)],
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    store.name,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
                          Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              store.storeLocation.address,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
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

                      // Chat
                    ],
                  ),
                ),
              ),
              if (menu == null)
                const SliverToBoxAdapter(
                  child: Padding(padding: EdgeInsets.all(16.0), child: Center(child: Text('Chưa có thực đơn'))),
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
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              sliver: ProductListWidget(group: group, vm: vm, store: store),
                            ),
                          )
                          .toList(),
                ),
            ],
          );
        }),
      ),
      floatingActionButton: Obx(() {
        final cartItems = cartVm.cart.value?.items ?? [];
        final itemCount = cartItems
            .where((item) => item.storeId == store.storeId)
            .fold<int>(0, (sum, item) => sum + item.quantity.value);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                Get.toNamed(AppRoutes.cart);
              },
              child: const Icon(Icons.shopping_cart, color: AppColors.background),
            ),
            if (itemCount > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
                  ),
                  child: Text(
                    '$itemCount',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

      