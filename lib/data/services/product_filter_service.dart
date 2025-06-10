import 'package:agrimarket/data/models/product.dart';

class ProductFilterService {
  List<ProductModel> filterProducts(
    List<ProductModel> products,
    String storeId,
    String selectedCategory,
    String searchQuery,
  ) {
    var filtered = products.where((product) => product.storeId == storeId).toList();

    if (selectedCategory.isNotEmpty) {
      filtered = filtered.where((product) => product.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((product) => product.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }
}