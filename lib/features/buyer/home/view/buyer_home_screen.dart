import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/core/widgets/store_product_list.dart';
import 'package:agrimarket/core/widgets/storetile.dart';
import 'package:agrimarket/data/models/buyer.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/address_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/home/view/nearby_stores.dart';
import 'package:agrimarket/features/buyer/home/view/promotion_store_horizontal_list.dart';
import 'package:agrimarket/features/buyer/home/view/recommended_store_horizontal_list.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/store_vm.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/recommendation_vm.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeBuyerScreen extends StatelessWidget {
  final BuyerVm vm = Get.find<BuyerVm>();
  final StoreVm storeVm = Get.find<StoreVm>();

  HomeBuyerScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

                if (storeVm.storesListPromotion.isNotEmpty) ...[
                  _buildSectionHeader(
                    "Ưu đãi nhập trời",
                    actionText: "Xem tất cả",
                    actionRoute: AppRoutes.storePromotionList,
                  ),
                  PromotionStoreHorizontalList(),
                ],
                Obx(() {
                  final recoVm = Get.find<RecommendationVm>();
                  if (recoVm.recommendedStores.isEmpty) return SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildSectionHeader("Dành cho bạn"), const RecommendedStoreHorizontalList()],
                  );
                }),
                Obx(() {
                  final recoVm = Get.find<RecommendationVm>();
                  if (recoVm.nearbyStores.isEmpty) return SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildSectionHeader("Gần bạn"), const NearbyStores()],
                  );
                }),

                _buildStoreList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final UserVm userVm = Get.find<UserVm>();
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: CircleAvatar(
          backgroundImage:
              userVm.userAvatar.value.isNotEmpty && userVm.userAvatar.value.startsWith('http')
                  ? NetworkImage(userVm.userAvatar.value)
                  : AssetImage('assets/images/avatar.png') as ImageProvider,
          radius: 20,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, ${userVm.userName} 👋',
            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.buyerAddress);
            },
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.green, size: 16),
                SizedBox(width: 2),
                Flexible(
                  child: Text(
                    vm.defaultAddress?.address ?? '... Loading',
                    style: TextStyle(color: Colors.black, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        autoPlay: false, // Tắt autoPlay để tránh lỗi
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

  // --- Category Icons ---
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

    final List<Color> bgColors = [
      Colors.green.shade100,
      Colors.orange.shade100,
      Colors.pink.shade100,
      Colors.blue.shade100,
      Colors.purple.shade100,
      Colors.teal.shade100,
      Colors.yellow.shade100,
      Colors.red.shade100,
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 14),
        itemCount: items.length,
        itemBuilder:
            (_, index) => InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () {
                Get.toNamed(AppRoutes.categoryStoreScreen, arguments: items[index]);
              },
              child: SizedBox(
                width: 80,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: bgColors[index % bgColors.length],
                      child: Image.asset(imageCategory[index], width: 38, height: 38),
                    ),
                    SizedBox(height: 6),
                    Text(
                      items[index],
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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

  // --- Section Header ---
  Widget _buildSectionHeader(String title, {String? actionText, String? actionRoute, dynamic arguments}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green.shade800, // xanh đậm cho header
            ),
          ),
          if (actionText != null)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange, // nút xem tất cả màu cam
                padding: EdgeInsets.zero,
                minimumSize: Size(50, 30),
              ),
              onPressed: () {
                Get.toNamed(actionRoute ?? '', arguments: arguments);
              },
              child: Text(actionText),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreItem(StoreModel store, BuyerModel buyer) {
    final addressService = AddressService();
    final storeLatLng = store.getDefaultLatLng();
    final buyerLatLng = buyer.getDefaultLatLng();

    if (storeLatLng == null || buyerLatLng == null) {
      return StoreTile(store: store, distanceText: null, estimatedTime: null);
    }

    final distance = addressService.calculateDistance(buyerLatLng[0], buyerLatLng[1], storeLatLng[0], storeLatLng[1]);
    final formattedDistance = NumberFormat('#,##0.00', 'vi_VN').format(distance);

    return FutureBuilder<int>(
      future: addressService.getEstimatedTravelTime(storeLatLng[0], storeLatLng[1], buyerLatLng[0], buyerLatLng[1]),
      builder: (context, snapshot) {
        final estimatedTime = snapshot.hasData ? snapshot.data! : 0;
        final int prepareTime = 15;
        final int totalTime = prepareTime + estimatedTime;

        return StoreTile(store: store, distanceText: '$formattedDistance km', estimatedTime: totalTime);
      },
    );
  }

  Widget _buildStoreList() {
    final StoreVm storeVm = Get.find<StoreVm>();
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: storeVm.storesList.length + 1, // +1 để thêm widget đặc biệt
      itemBuilder: (context, index) {
        final buyer = vm.buyerData.value;
        if (buyer == null) {
          return SizedBox.shrink();
        }
        if (index == 7) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Bỗng dưng thèm trái ngọt", actionText: "Xem tất cả"),
              StoreProductList(storeId: 'store_Fs06RKoGxPfrFuxY8E78FtyRByD2_8165'),
            ],
          );
        }

        if (index >= storeVm.storesList.length) return SizedBox.shrink();
        final store = storeVm.storesList[index];
        return _buildStoreItem(store, buyer);
      },
    );
  }
}
