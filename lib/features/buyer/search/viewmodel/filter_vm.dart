import 'package:agrimarket/data/models/store_product.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class FilterVm extends GetxController {
  // Danh sách danh mục
  final List<String> categories = [
    "Trái cây",
    "Rau củ",
    "Thực phẩm chế biến",
    "Thuỷ hải sản",
    "Thịt",
    "Sữa & Trứng",
    "Ngũ cốc - Hạt",
    "Gạo",
  ];

  // Tùy chọn rating (>=)
  final List<int> ratingOptions = [3, 4, 5];

  // Tùy chọn khoảng giá
  final List<Map<String, double>> priceOptions = [
    {"min": 0, "max": 100000},       
    {"min": 100000, "max": 300000},  
    {"min": 300000, "max": 500000},  
    {"min": 500000, "max": double.infinity}, 
  ];

  // Lựa chọn khoảng giá hiện tại
  final RxInt selectedPriceIndex = (-1).obs; // -1 nghĩa chưa chọn

  // Controllers (có thể bỏ nếu không dùng nhập tay nữa)
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  // Rx variables
  final RxDouble from = 0.0.obs;
  final RxDouble to = double.infinity.obs;
  final RxString category = ''.obs;
  final RxInt rating = 0.obs;

  final RxList<ProductModelWithStore> filterResults =
      <ProductModelWithStore>[].obs;
  RxList<ProductModelWithStore> searchResults =
      <ProductModelWithStore>[].obs;

  final RxList<String> filterKeywords = <String>[].obs;
  final RxBool upperPrice = true.obs;
  final RxBool upperSold = true.obs;

  @override
  void onInit() {
    super.onInit();
    resetFilters();
  }

  void resetFilters() {
    filterKeywords.clear();
    category.value = '';
    rating.value = 0;
    from.value = 0.0;
    to.value = double.infinity;
    selectedPriceIndex.value = -1;
    upperPrice.value = true;
    upperSold.value = true;
    fromController.clear();
    toController.clear();
  }

  void addKeyword(String keyword) {
    if (!filterKeywords.contains(keyword)) {
      filterKeywords.add(keyword);
    }
  }

  void removeKeyword(String keyword) {
    filterKeywords.remove(keyword);
  }

  void setUpperPrice() {
    upperPrice.value = !upperPrice.value;
    applyFilters();
  }

  void setUpperSold() {
    upperSold.value = !upperSold.value;
    applyFilters();
  }

  void applyFilters() {
    var results = List<ProductModelWithStore>.from(searchResults);

    // Lọc theo giá
    if (filterKeywords.contains("price")) {
      if (upperPrice.value) {
        results.sort((a, b) => a.getPrice().compareTo(b.getPrice()));
      } else {
        results.sort((a, b) => b.getPrice().compareTo(a.getPrice()));
      }
    }

    // Lọc theo lượt mua
    if (filterKeywords.contains("sold")) {
      if (upperSold.value) {
        results.sort(
            (a, b) => a.product.totalSold.compareTo(b.product.totalSold));
      } else {
        results.sort(
            (a, b) => b.product.totalSold.compareTo(a.product.totalSold));
      }
    }

    // Lọc theo khoảng giá nếu đã chọn
    if (selectedPriceIndex.value >= 0) {
      final option = priceOptions[selectedPriceIndex.value];
      from.value = option["min"]!;
      to.value = option["max"]!;
      results = results
          .where((p) => p.product.price >= from.value && p.product.price <= to.value)
          .toList();
    }

    // Lọc theo danh mục
    if (category.isNotEmpty) {
      results =
          results.where((p) => p.product.category == category.value).toList();
    }

    // Lọc theo rating cửa hàng
    if (rating.value > 0) {
      results = results
          .where((p) => (p.store?.rating ?? 0) >= rating.value)
          .toList();
    }

    filterResults.assignAll(results);
  }
}
