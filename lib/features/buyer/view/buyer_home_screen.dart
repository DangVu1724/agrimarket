import 'package:agrimarket/features/buyer/viewmodel/buyer_vm%20.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeBuyerScreen extends StatelessWidget {
  final BuyerVm vm = Get.find<BuyerVm>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              SizedBox(height: 15),
              _buildBanner(),
              SizedBox(height: 15),
              _buildCategoryIcons(),
              _buildSectionHeader("Ưu đãi nhập trời", actionText: "See all"),
              _buildPromotionGrid(),
              _buildSectionHeader("Bồng dưng thèm trái ngọt", actionText: "Xem tất cả"),
              _buildProductList(),
              _buildStoreList(),
            ],
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
      title: Text("${vm.address.value}", style: TextStyle(color: Colors.black, fontSize: 16)),
      actions: [
        GestureDetector(
          onTap: () {
            Get.snackbar("San pham yeu thich", "CLick yeu thich");
          },
        child: Icon(Icons.favorite_border, color: Colors.black)),
        SizedBox(width: 15),
        GestureDetector(
          onTap: () {
            Get.snackbar("Gio hang", "Click gio hang");
          },
          child: Icon(Icons.shopping_cart_outlined, color: Colors.black)),
        SizedBox(width: 15),
      ],
    );
  } 


Widget _buildBanner() {
  final List<String> bannerImages = [
    "assets/images/bannerqc.png",
    "assets/images/bannerqc.png",
    "assets/images/bannerqc.png",
  ];

  return CarouselSlider(
    options: CarouselOptions(
      height: 200,
      enlargeCenterPage: true,         
      viewportFraction: 0.8,          
      enableInfiniteScroll: true,
      autoPlay: true,
    ),
    items: bannerImages.map((imageBanner) {
      return _buildBannerItem(imageBanner);
    }).toList(),
  );
}

Widget _buildBannerItem(String imageBanner) {
  return GestureDetector(
    onTap: () {
      Get.snackbar(
        "Banner Clicked",
        "Bạn đã nhấn vào banner"
      );
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        image: DecorationImage(
          image: AssetImage(imageBanner),
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}


  Widget _buildCategoryIcons() {
    
    final items = ['Trái cây', 'Rau củ', 'Thực phẩm chế biến', 'Ngũ cốc - Hạt','Sữa & Trứng', 'Thịt' , 'Thuỷ hải sản', 'Gạo'];
    final List<String> imageCategory = [
      "assets/images/fruit.png",
      "assets/images/vegetable.png",
      "assets/images/cooked_food.png",
      "assets/images/grain.png",
      "assets/images/milkAegg.png",
      "assets/images/meat.png",
      "assets/images/sea_food.png",
      "assets/images/rice.png"
    ];
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 14),
        itemCount: items.length,
        itemBuilder: (_, index) => GestureDetector(
          onTap: () {
            Get.snackbar(
              "Category Clicked",
              "Bạn đã nhấn vào danh mục ${items[index]}"
            );
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
                Text(items[index], style: TextStyle(fontSize: 12),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,maxLines: 2,)              
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
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (actionText != null)
            GestureDetector(
              onTap: () {
                Get.snackbar("Action Clicked", "Bạn đã nhấn vào $actionText");
              },
              child: Text(actionText, style: TextStyle(color: Colors.green)))
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

  Widget _buildProductList() {
    return Container(
      height: 150,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, index) => Container(
          width: 120,
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Expanded(child: Placeholder()),
              Padding(
                padding: EdgeInsets.all(4),
                child: Column(
                  children: [
                    Text("Nho đen", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("74.500  94.500", style: TextStyle(fontSize: 12)),
                    Text("Khoảng 500g", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreList() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: List.generate(2, (_) {
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(width: 60, height: 60, child: Placeholder()),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TH true mart - 45 Vũ Phạm Hàm", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("⭐ 4.8 (287) ~ Cửa hàng khác"),
                      Text("🚲 16.000đ ~ 15 phút"),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

}
