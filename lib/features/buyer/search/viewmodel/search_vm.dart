import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SearchVm extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxList<String> history = <String>[].obs;
  final RxMap<StoreModel, List<ProductModel>> searchResults = <StoreModel, List<ProductModel>>{}.obs;
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

  void _initializeSearchBox() {
    try {
      searchBox = Hive.box('searchCache');
      loadHistory();
      print('✅ Search box initialized successfully');
    } catch (e) {
      print('❌ Error initializing search box: $e');
      // Try to recreate the box
      try {
        Hive.deleteBoxFromDisk('searchCache');
        searchBox = Hive.openBox('searchCache') as Box;
        print('✅ Search box recreated successfully');
      } catch (e2) {
        print('❌ Error recreating search box: $e2');
      }
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
      if (searchBox != null) {
        searchBox!.put('search_history', history.toList());
        print('💾 Search history saved successfully');
      }
    } catch (e) {
      print('❌ Error saving search history: $e');
    }
  }

  void loadHistory() {
    try {
      if (searchBox != null) {
        final List<dynamic>? stored = searchBox!.get('search_history');
        if (stored != null) {
          history.assignAll(List<String>.from(stored));
          print('📦 Search history loaded: ${history.length} items');
        }
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

  Future<Map<StoreModel, List<ProductModel>>> fetchFilteredProductsWithStore({String searchQuery = ''}) async {
    try {
      final productSnapshot = await FirebaseFirestore.instance.collection('products').get();
      final storeSnapshot = await FirebaseFirestore.instance.collection('stores').get();

      final Map<String, StoreModel> storeMap = {
        for (var doc in storeSnapshot.docs)
          if ((doc.data()['state'] ?? '') == 'verify') doc.id: StoreModel.fromJson({...doc.data(), 'id': doc.id}),
      };
      final Map<StoreModel, List<ProductModel>> groupedResult = {};

      for (var doc in productSnapshot.docs) {
        final productData = {...doc.data(), 'id': doc.id};

        final product = ProductModel.fromJson(productData);

        final match =
            searchQuery.isEmpty ||
            product.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase())) ||
            product.name.toLowerCase().contains(searchQuery.toLowerCase());

        if (!match) continue;
        final store = storeMap[product.storeId];
        if (store == null) continue;

        groupedResult.putIfAbsent(store, () => []).add(product);
      }

      return groupedResult;
    } catch (e) {
      return {};
    }
  }
}
