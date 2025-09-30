import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/models/store_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
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
  Box? searchBox;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchText.value = searchController.text;
    });
    _initializeSearchBox();
  }

  Future<void> _initializeSearchBox() async {
    try {
      if (!Hive.isBoxOpen('searchCache')) {
        searchBox = await Hive.openBox('searchCache');
      } else {
        searchBox = Hive.box('searchCache');
      }
      loadHistory();
    } catch (e) {
      try {
        await Hive.deleteBoxFromDisk('searchCache');
        searchBox = await Hive.openBox('searchCache');
      } catch (_) {}
    }
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
    try {
      searchBox ??= Hive.box('searchCache');
      searchBox!.put('search_history', history.toList());
      print('💾 Search history saved successfully');
    } catch (e) {
      print('❌ Error saving search history: $e');
    }
  }

  void loadHistory() {
    try {
      searchBox ??= Hive.box('searchCache');
      final List<dynamic>? stored = searchBox!.get('search_history');
      if (stored != null) {
        history.assignAll(List<String>.from(stored));
        print('📦 Search history loaded: ${history.length} items');
      }
    } catch (e) {
      print('❌ Error loading search history: $e');
      // Clear corrupted history
      history.clear();
    }
  }

  void clearHistory() {
    try {
      history.clear();
      if (searchBox != null) {
        searchBox!.delete('search_history');
        print('🗑️ Search history cleared successfully');
      }
    } catch (e) {
      print('❌ Error clearing search history: $e');
    }
  }

  bool containsIgnoreDiacritics(String source, String query) {
    return removeDiacritics(source.toLowerCase()).contains(removeDiacritics(query.toLowerCase()));
  }

  Future<List<ProductModelWithStore>> fetchFilteredProductsWithStore({String searchQuery = ''}) async {
    try {
      final productSnapshot = await FirebaseFirestore.instance.collection('products').get();
      final storeSnapshot = await FirebaseFirestore.instance.collection('stores').get();

      final Map<String, StoreModel> storeMap = {
        for (var doc in storeSnapshot.docs)
          if ((doc.data()['state'] ?? '') == 'verify') doc.id: StoreModel.fromJson({...doc.data(), 'id': doc.id}),
      };

      final Map<String, ProductModelWithStore> representativeProducts = {};

      for (var doc in productSnapshot.docs) {
        final productData = {...doc.data(), 'id': doc.id};

        final product = ProductModel.fromJson(productData);

        final match =
            searchQuery.isEmpty ||
            product.tags.any((tag) => containsIgnoreDiacritics(tag, searchQuery)) ||
            containsIgnoreDiacritics(product.name, searchQuery);

        if (!match) {
          continue;
        }

        final store = storeMap[product.storeId];
        if (store == null) continue;

        if (!representativeProducts.containsKey(store.storeId)) {
          representativeProducts[store.storeId] = ProductModelWithStore(product: product, store: store);
        }
      }
      return representativeProducts.values.toList();
    } catch (e) {
      return [];
    }
  }
}
