import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/store_product_list.dart';
import 'package:agrimarket/core/widgets/promotion_badge.dart';
import 'package:agrimarket/core/widgets/storetile.dart';
import 'package:agrimarket/data/models/buyer.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/address_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/home/view/promotion_store_horizontal_list.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/store_vm.dart';
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
                _buildSectionHeader(
                  "Ưu đãi nhập trời",
                  actionText: "Xem tất cả",
                  actionRoute: AppRoutes.storePromotionList,
                ),
                PromotionStoreHorizontalList(),
                _buildSectionHeader("Bỗng dưng thèm trái ngọt", actionText: "Xem tất cả"),
                StoreProductList(storeId: 'store_Fs06RKoGxPfrFuxY8E78FtyRByD2_8165'),
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
        child: Text(vm.defaultAddress?.address ?? '... Loading', style: TextStyle(color: Colors.black, fontSize: 16)),
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
                Get.toNamed(AppRoutes.categoryStoreScreen, arguments: items[index]);
              },
              child: SizedBox(
                width: 80,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      child: Image.asset(imageCategory[index], width: 40, height: 40, fit: BoxFit.cover),
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

  Widget _buildSectionHeader(String title, {String? actionText, String? actionRoute, dynamic arguments}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (actionText != null)
            GestureDetector(
              onTap: () {
                Get.toNamed(actionRoute ?? '', arguments: arguments);
              },
              child: Text(actionText, style: TextStyle(color: Colors.green)),
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
      itemCount: storeVm.storesList.length,
      itemBuilder: (context, index) {
        final store = storeVm.storesList[index];
        final buyer = vm.buyerData.value;
        if (buyer == null) {
          return SizedBox.shrink();
        }
        return _buildStoreItem(store, buyer);
      },
    );
  }
}
