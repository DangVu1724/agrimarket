import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/core/widgets/store_product_list.dart';
import 'package:agrimarket/core/widgets/storetile.dart';
import 'package:agrimarket/data/models/buyer.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/address_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/home/view/hot_sale.dart';
import 'package:agrimarket/features/buyer/home/view/nearby_stores.dart';
import 'package:agrimarket/features/buyer/home/view/promotion_store_horizontal_list.dart';
import 'package:agrimarket/features/buyer/home/view/recommended_store_horizontal_list.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/store_vm.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/recommendation_vm.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class HomeBuyerScreen extends StatelessWidget {
  final BuyerVm vm = Get.find<BuyerVm>();
  final StoreVm storeVm = Get.find<StoreVm>();

  HomeBuyerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 251, 244),
      body: RefreshIndicator(
        onRefresh: () async {
          storeVm.fetchStoresList();
        },
        child: Obx(
          () => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.green,
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      _buildAppBar(),
                      SizedBox(height: 25),
                      _buildBanner(),
                      SizedBox(height: 25),
                      Container(
                        padding: EdgeInsets.only(top: 15),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.lightGreen,
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                        child: _buildCategoryIcons(),
                      ),
                    ],
                  ),
                ),

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
                  return RecommendedStoreHorizontalList();
                }),
                Obx(() {
                  final recoVm = Get.find<RecommendationVm>();
                  if (recoVm.nearbyStores.isEmpty) return SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Gần bạn"),
                      const NearbyStores(),
                    ],
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
      backgroundColor: Colors.green,
      elevation: 0,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: CircleAvatar(
          backgroundImage:
              userVm.userAvatar.value.isNotEmpty &&
                      userVm.userAvatar.value.startsWith('http')
                  ? NetworkImage(userVm.userAvatar.value)
                  : AssetImage('assets/images/avatar.png') as ImageProvider,
          radius: 20,
        ),
      ),
      title: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, ${userVm.userName}',
              style: TextStyle(
                color: const Color.fromARGB(255, 44, 101, 46),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.buyerAddress);
              },
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.orangeAccent, size: 16),
                  SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      vm.defaultAddress?.address ?? '... Loading',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.favourite);
          },
          child: Icon(Iconsax.heart_circle, color: Colors.white, size: 30),
        ),
        SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.cart);
          },
          child: Icon(Iconsax.shopping_cart, color: Colors.white, size: 30),
        ),
        SizedBox(width: 10),
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
      child: Container(
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(imageBanner, fit: BoxFit.cover, height: 200),
        ),
      ),
    );
  }

  // --- Category Icons ---
  Widget _buildCategoryIcons() {
    final items = [
      'Trái cây',
      'Rau củ',
      'Thực phẩm chế biến',
      'Ngũ cốc & Hạt',
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
      const Color.fromARGB(255, 214, 255, 197),
      Colors.yellow.shade200,
      const Color.fromARGB(255, 214, 255, 197),
      Colors.yellow.shade200,
      const Color.fromARGB(255, 214, 255, 197),
      Colors.yellow.shade200,
      const Color.fromARGB(255, 214, 255, 197),
      Colors.yellow.shade200,
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
                      radius: 32,
                      backgroundColor: bgColors[index % bgColors.length],
                      child: Image.asset(
                        imageCategory[index],
                        width: 38,
                        height: 38,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      items[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
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
  Widget _buildSectionHeader(
    String title, {
    String? actionText,
    String? actionRoute,
    dynamic arguments,
  }) {
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
      return StoreTile(store: store, distanceText: null, estimatedTime: null,);
    }

    final distance = addressService.calculateDistance(
      buyerLatLng[0],
      buyerLatLng[1],
      storeLatLng[0],
      storeLatLng[1],
    );
    final formattedDistance = NumberFormat(
      '#,##0.00',
      'vi_VN',
    ).format(distance);

    return FutureBuilder<int>(
      future: addressService.getEstimatedTravelTime(
        storeLatLng[0],
        storeLatLng[1],
        buyerLatLng[0],
        buyerLatLng[1],
      ),
      builder: (context, snapshot) {
        final estimatedTime = snapshot.hasData ? snapshot.data! : 0;
        final int prepareTime = 15;
        final int totalTime = prepareTime + estimatedTime;

        return StoreTile(
          store: store,
          distanceText: '$formattedDistance km',
          estimatedTime: totalTime,
        );
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
              const SizedBox(height: 15),
              HotSaleHorizontalList(),
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
