import 'package:agrimarket/data/models/store_product.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class FilterVm extends GetxController {
  // RxList kết quả lọc
  final RxList<ProductModelWithStore> filterResults =
      <ProductModelWithStore>[].obs;

  // TextEditingController cho khoảng giá
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  // Khoảng giá
  final RxDouble from = 0.0.obs;
  final RxDouble to = double.infinity.obs;

  // Store được lọc
  final RxString store = ''.obs;

  //
  final RxBool upperPrice = true.obs;
  final RxBool upperSold = true.obs;

  // Keywords hiện tại
  final RxList<String> filterKeywords = <String>[].obs;

  // Danh sách gốc sản phẩm
  RxList<ProductModelWithStore> searchResults = <ProductModelWithStore>[].obs;

@override
  void onInit() {
    super.onInit();
    filterKeywords.clear();
    store.value='';
    from.value = 0.0;
    to.value = double.infinity;
    upperPrice.value = true;
    upperSold.value = true;
  }
  /// Áp dụng tất cả bộ lọc dựa trên keywords
  void applyFilters() {
    var results = List<ProductModelWithStore>.from(searchResults);
    // Lọc theo sold
    if (filterKeywords.contains("sold")) {
      if (upperSold.value) {
        results.sort((a, b) => a.getSold().compareTo(b.getSold()));
      } else {
        results.sort((a, b) => b.getSold().compareTo(a.getSold()));
      }
    }

    // Lọc giá trên / dưới
    if (filterKeywords.contains("price")) {
      if (upperPrice.value) {
        results.sort((a, b) => a.getPrice().compareTo(b.getPrice()));
      } else {
        results.sort((a, b) => b.getPrice().compareTo(a.getPrice()));
      }
    }

    // Lọc theo khoảng giá
    if (filterKeywords.contains("range")) {
      results =
          results
              .where(
                (p) =>
                    p.product.price >= from.value &&
                    p.product.price <= to.value,
              )
              .toList();
    }

    // Lọc theo cửa hàng
    if (filterKeywords.contains("store") && store.isNotEmpty) {
      results = results.where((p) => p.store?.name == store.value).toList();
    }

    // Cập nhật danh sách reactive
    filterResults.assignAll(results);
  }
  void removeFilters(){
    filterKeywords.clear();
  }

  void setUpperPrice() {
    upperPrice.value = !upperPrice.value;
  }

  void setUpperSold() {
    upperSold.value = !upperSold.value;
  }

  /// Tiện ích thêm / xoá keyword
  void addKeyword(String keyword) {
    if (!filterKeywords.contains(keyword)) filterKeywords.add(keyword);
  }

  void removeKeyword(String keyword) {
    if (filterKeywords.contains(keyword)) {
      filterKeywords.remove(keyword);
    }
  }
  void setRange(){
    from.value = fromController.text.isEmpty?0.0:double.parse(fromController.text);
    to.value = toController.text.isEmpty?double.infinity:double.parse(toController.text);
  }
}
