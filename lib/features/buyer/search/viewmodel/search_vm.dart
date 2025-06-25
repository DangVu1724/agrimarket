import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/models/store_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SearchVm extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxList<String> history = <String>[].obs;
  final RxList<ProductModelWithStore> searchResults = <ProductModelWithStore>[].obs;
  final RxString searchText = ''.obs;
  final RxBool isSearching = false.obs;
  final RxBool hasSearched = false.obs;
  late Box searchBox;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchText.value = searchController.text;
    });
    searchBox = Hive.box('searchCache');
    loadHistory();
  }

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) return;
    isSearching.value = true;
    hasSearched.value = true;

    final results = await fetchFilteredProductsWithStore(searchQuery: query);
    searchResults.assignAll(results);

    addToHistory(query);
    isSearching.value = false;
  }

  void addToHistory(String keyword) {
    keyword = keyword.trim();
    if (keyword.isEmpty) return;

    history.remove(keyword);
    history.insert(0, keyword);

    if (history.length > 5) {
      history.removeLast();
    }

    saveHistory();
  }

  void saveHistory() {
    searchBox.put('search_history', history.toList());
  }

  void loadHistory() {
    final List<dynamic>? stored = searchBox.get('search_history');
    if (stored != null) {
      history.assignAll(List<String>.from(stored));
    }
  }

  void clearHistory() {
    history.clear();
    searchBox.delete('search_history');
  }

  Future<List<ProductModelWithStore>> fetchFilteredProductsWithStore({String searchQuery = ''}) async {
    try {
      final productSnapshot = await FirebaseFirestore.instance.collection('products').get();
      final storeSnapshot = await FirebaseFirestore.instance.collection('stores').get();

      final Map<String, StoreModel> storeMap = {
        for (var doc in storeSnapshot.docs)
          if ((doc.data()['state'] ?? '') == 'verify') doc.id: StoreModel.fromJson({...doc.data(), 'id': doc.id}),
      };
      List<ProductModelWithStore> productsWithStore = [];
      for (var doc in productSnapshot.docs) {
        final productData = {...doc.data(), 'id': doc.id};

        final product = ProductModel.fromJson(productData);

        if (searchQuery.isNotEmpty && !product.name.toLowerCase().contains(searchQuery.toLowerCase())) {
          continue;
        }
        final store = storeMap[product.storeId];
        if (store == null) continue;

        productsWithStore.add(ProductModelWithStore(product: product, store: store));
      }
      return productsWithStore;
    } catch (e) {
      return [];
    }
  }
}
