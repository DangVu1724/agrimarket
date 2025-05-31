import 'package:agrimarket/features/buyer/viewmodel/home_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeBuyerScreen extends StatelessWidget {
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            _buildBanner(),
            _buildCategoryIcons(),
            _buildSectionHeader("Ưu đãi nhập trời", actionText: "See all"),
            _buildPromotionGrid(),
            _buildSectionHeader("Bồng dưng thèm trái ngọt", actionText: "Xem tất cả"),
            _buildProductList(),
            _buildStoreList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Icon(Icons.location_on, color: Colors.black),
      title: Text("61 Hopper street..", style: TextStyle(color: Colors.black)),
      actions: [
        Icon(Icons.favorite_border, color: Colors.black),
        SizedBox(width: 10),
        Icon(Icons.shopping_cart_outlined, color: Colors.black),
        SizedBox(width: 10),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: EdgeInsets.all(16),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                 
                ],
              ),
            ),
          ),
          Container(
            width: 100,
            child: Placeholder(), 
          )
        ],
      ),
    );
  }

  Widget _buildCategoryIcons() {
    final items = ["Hoa quả", "Sữa & Trứng", "Đồ uống", "Thịt", "Rau củ"];
    return Container(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (_, index) => Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey.shade200,
              child: Icon(Icons.image),
            ),
            SizedBox(height: 6),
            Text(items[index], style: TextStyle(fontSize: 12))
          ],
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
            Text(actionText, style: TextStyle(color: Colors.green))
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

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm kiếm"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Đơn hàng"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Hồ sơ"),
      ],
    );
  }
}
