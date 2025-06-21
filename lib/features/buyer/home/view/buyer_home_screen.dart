import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/store_product_list.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/store_vm.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeBuyerScreen extends StatelessWidget {
  final BuyerVm vm = Get.find<BuyerVm>();
  final StoreVm storeVm = Get.find<StoreVm>();

  @override
  Widget build(BuildContext context) {
    storeVm.fetchStoresList();
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          storeVm.fetchStoresList();
        },
        child: Obx(
          () => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                SizedBox(height: 15),
                _buildBanner(),
                SizedBox(height: 15),
                _buildCategoryIcons(),
                _buildSectionHeader("Ưu đãi nhập trời", actionText: "Xem tất cả"),
                _buildPromotionGrid(),
                _buildSectionHeader(
                  "Bỗng dưng thèm trái ngọt",
                  actionText: "Xem tất cả",
                ),
                StoreProductList(storeId: 'store_Fs06RKoGxPfrFuxY8E78FtyRByD2_8165',),
                _buildStoreList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Icon(Icons.location_on, color: Colors.black, size: 20),
      title: GestureDetector(
        onTap: () {
          Get.toNamed(AppRoutes.buyerAddress);
        },
        child: Text(
          vm.defaultAddress,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.favourite);
          },
          child: Icon(Icons.favorite_border, color: Colors.black),
        ),
        SizedBox(width: 15),
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.cart);
          },
          child: Icon(Icons.shopping_cart_outlined, color: Colors.black),
        ),
        SizedBox(width: 15),
      ],
    );
  }

  Widget _buildBanner() {
    final List<String> bannerImages = [
      "assets/images/bannerqc.png",
      "assets/images/bannerqc2.jpg",
      "assets/images/bannerqc3.jpg",
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
        enableInfiniteScroll: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
      ),
      items:
          bannerImages.map((imageBanner) {
            return _buildBannerItem(imageBanner);
          }).toList(),
    );
  }

  Widget _buildBannerItem(String imageBanner) {
    return GestureDetector(
      onTap: () {
        Get.snackbar("Banner Clicked", "Bạn đã nhấn vào banner");
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(imageBanner, fit: BoxFit.cover, height: 200),
      ),
    );
  }

  Widget _buildCategoryIcons() {
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
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 14),
        itemCount: items.length,
        itemBuilder:
            (_, index) => GestureDetector(
              onTap: () {
                Get.toNamed(
                  AppRoutes.categoryStoreScreen,
                  arguments: items[index],
                );
              },
              child: SizedBox(
                width: 80,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      child: Image.asset(
                        imageCategory[index],
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      items[index],
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? actionText}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: () {
                Get.snackbar("Action Clicked", "Bạn đã nhấn vào $actionText");
              },
              child: Text(actionText, style: TextStyle(color: Colors.green)),
            ),
        ],
      ),
    );
  }

  Widget _buildPromotionGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          3,
          (_) => Expanded(
            child: Container(
              margin: EdgeInsets.all(4),
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text("Khuyến mãi", style: TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreItem(StoreModel store) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.store, arguments: store.storeId);
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                store.storeImageUrl ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.store, size: 50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: AppTextStyles.headline.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    store.address,
                    style: AppTextStyles.body.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreList() {
    final StoreVm storeVm = Get.find<StoreVm>();
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: storeVm.storesList.length,
      itemBuilder: (context, index) {
        final store = storeVm.storesList[index];
        return _buildStoreItem(store);
      },
    );
  }
}
