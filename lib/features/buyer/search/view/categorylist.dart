import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
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