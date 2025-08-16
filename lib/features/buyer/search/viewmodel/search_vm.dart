import 'dart:async';
import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/services/address_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum SortOption { recommended, priceLowToHigh, priceHighToLow, popular, ratingHigh, newest, distance }

class SearchVm extends GetxController {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  final RxList<String> history = <String>[].obs;
  // Raw results from backend
  final RxMap<StoreModel, List<ProductModel>> _allResults = <StoreModel, List<ProductModel>>{}.obs;
  // Visible results after applying filters/sorting
  final RxMap<StoreModel, List<ProductModel>> filteredResults = <StoreModel, List<ProductModel>>{}.obs;
  final RxString searchText = ''.obs;
  final RxBool isSearching = false.obs;
  final RxBool hasSearched = false.obs;
  Box? searchBox;

  RxString selectedFilter = ''.obs;
  final RxBool isPanelOpen = false.obs;

  // Filters
  final RxBool promotionOnly = false.obs; // Chip: Khuyến mãi
  final RxBool newestOnly = false.obs; // Chip: Mới nhất (acts like sort by store.createdAt desc)
  final Rx<SortOption> sortOption = SortOption.recommended.obs; // Panel: Lọc theo
  final RxSet<String> selectedCategories = <String>{}.obs; // Panel: Ẩm thực

  void selectFilter(String filter) {
    selectedFilter.value = filter;
    // For action chips opening panel; actual logic handled via dedicated setters
  }

  void clearFilter() {
    selectedFilter.value = '';
    promotionOnly.value = false;
    newestOnly.value = false;
    sortOption.value = SortOption.recommended;
    selectedCategories.clear();
    _applyFilters();
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchText.value = searchController.text;
      hasSearched.value = false;
    });
    _initializeSearchBox();
    clearFilter();
  }

  @override
  void onClose() {
    // Reset filter state when leaving the screen/controller is disposed
    clearFilter();
    isSearching.value = false;
    hasSearched.value = false;
    super.onClose();
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

  Future<void> searchProducts(String query, {bool saveToHistory = true}) async {
    if (query.trim().isEmpty) return;
    isSearching.value = true;
    hasSearched.value = false;

    final results = await fetchFilteredProductsWithStore(searchQuery: query);
    _allResults.assignAll(results);
    _applyFilters();

    if (saveToHistory) {
      addToHistory(query);
    }
    isSearching.value = false;
    hasSearched.value = true;
  }

  void clearResults() {
    _allResults.clear();
    filteredResults.clear();
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

  void onQueryChanged(String text) {
    searchText.value = text;
    hasSearched.value = false;
    _debounce?.cancel();
    if (text.trim().isEmpty) {
      clearResults();
      return;
    }
    if (text.trim().length < 2) {
      // Avoid spamming queries for single characters
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () {
      searchProducts(text, saveToHistory: false);
    });
  }

  void saveHistory() {
    try {
      // Ensure box is available (it should already be opened in main via CacheUtils.openAllBoxes)
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
      searchBox ??= Hive.box('searchCache');
      searchBox!.delete('search_history');
      print('🗑️ Search history cleared successfully');
    } catch (e) {
      print('❌ Error clearing search history: $e');
    }
  }

  bool containsIgnoreDiacritics(String source, String query) {
    return removeDiacritics(source.toLowerCase()).contains(removeDiacritics(query.toLowerCase()));
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
            product.tags.any((tag) => containsIgnoreDiacritics(tag, searchQuery)) ||
            containsIgnoreDiacritics(product.name, searchQuery);

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

  // Public setters to update filter state and re-apply
  void togglePromotion() {
    promotionOnly.value = !promotionOnly.value;
    _applyFilters();
  }

  void toggleNewest() {
    newestOnly.value = !newestOnly.value;
    // When newestOnly is on, prefer newest sort
    if (newestOnly.value) {
      sortOption.value = SortOption.newest;
    } else if (sortOption.value == SortOption.newest) {
      sortOption.value = SortOption.recommended;
    }
    _applyFilters();
  }

  void setSortOption(SortOption option) {
    sortOption.value = option;
    // Keep newestOnly in sync
    newestOnly.value = option == SortOption.newest;
    _applyFilters();
  }

  void setCategories(Set<String> categories) {
    selectedCategories
      ..clear()
      ..addAll(categories);
    _applyFilters();
  }

  // Core filtering + sorting logic
  void _applyFilters() {
    final Map<StoreModel, List<ProductModel>> working = {};

    _allResults.forEach((store, products) {
      // Category filtering (product-level)
      Iterable<ProductModel> current = products;
      if (selectedCategories.isNotEmpty) {
        current = current.where((p) => selectedCategories.contains(p.category));
      }

      // Promotion-only filtering (product-level)
      if (promotionOnly.value) {
        current = current.where((p) => p.isOnSale);
      }

      final List<ProductModel> kept = current.toList();
      if (kept.isNotEmpty) {
        working[store] = kept;
      }
    });

    // Sorting
    final List<MapEntry<StoreModel, List<ProductModel>>> entries = working.entries.toList();

    int compareByPriceAsc(MapEntry<StoreModel, List<ProductModel>> a, MapEntry<StoreModel, List<ProductModel>> b) {
      double aMin = a.value.map((p) => p.displayPrice).fold<double>(double.infinity, (min, v) => v < min ? v : min);
      double bMin = b.value.map((p) => p.displayPrice).fold<double>(double.infinity, (min, v) => v < min ? v : min);
      return aMin.compareTo(bMin);
    }

    int compareByPriceDesc(MapEntry<StoreModel, List<ProductModel>> a, MapEntry<StoreModel, List<ProductModel>> b) {
      return -compareByPriceAsc(a, b);
    }

    int compareByPopularity(MapEntry<StoreModel, List<ProductModel>> a, MapEntry<StoreModel, List<ProductModel>> b) {
      int aSold = a.value.fold<int>(0, (sum, p) => sum + p.totalSold);
      int bSold = b.value.fold<int>(0, (sum, p) => sum + p.totalSold);
      return bSold.compareTo(aSold);
    }

    int compareByRating(MapEntry<StoreModel, List<ProductModel>> a, MapEntry<StoreModel, List<ProductModel>> b) {
      double aRating = a.key.rating ?? a.key.getAverageRating() ?? 0.0;
      double bRating = b.key.rating ?? b.key.getAverageRating() ?? 0.0;
      if (bRating.compareTo(aRating) != 0) return bRating.compareTo(aRating);
      // Tie-breaker by popularity
      return compareByPopularity(a, b);
    }

    int compareByNewest(MapEntry<StoreModel, List<ProductModel>> a, MapEntry<StoreModel, List<ProductModel>> b) {
      final aCreated = a.key.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bCreated = b.key.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bCreated.compareTo(aCreated);
    }

    int compareByDistance(MapEntry<StoreModel, List<ProductModel>> a, MapEntry<StoreModel, List<ProductModel>> b) {
      try {
        final buyerVm = Get.isRegistered<BuyerVm>() ? Get.find<BuyerVm>() : null;
        final buyer = buyerVm?.buyerData.value;
        final buyerLatLng = buyer?.getDefaultLatLng();
        if (buyerLatLng == null) return 0;

        final aLatLng = a.key.getDefaultLatLng();
        final bLatLng = b.key.getDefaultLatLng();
        if (aLatLng == null && bLatLng == null) return 0;
        if (aLatLng == null) return 1;
        if (bLatLng == null) return -1;

        final addressService = AddressService();
        final aDist = addressService.calculateDistance(buyerLatLng[0], buyerLatLng[1], aLatLng[0], aLatLng[1]);
        final bDist = addressService.calculateDistance(buyerLatLng[0], buyerLatLng[1], bLatLng[0], bLatLng[1]);
        return aDist.compareTo(bDist);
      } catch (_) {
        return 0;
      }
    }

    switch (sortOption.value) {
      case SortOption.priceLowToHigh:
        entries.sort(compareByPriceAsc);
        break;
      case SortOption.priceHighToLow:
        entries.sort(compareByPriceDesc);
        break;
      case SortOption.popular:
        entries.sort(compareByPopularity);
        break;
      case SortOption.ratingHigh:
        entries.sort(compareByRating);
        break;
      case SortOption.distance:
        entries.sort(compareByDistance);
        break;
      case SortOption.newest:
        entries.sort(compareByNewest);
        break;
      case SortOption.recommended:
        // Hybrid: rating then popularity then price asc
        entries.sort((a, b) {
          final r = compareByRating(a, b);
          if (r != 0) return r;
          final p = compareByPopularity(a, b);
          if (p != 0) return p;
          return compareByPriceAsc(a, b);
        });
        break;
    }

    // Within each store, also sort product list according to price when applicable
    if (sortOption.value == SortOption.priceLowToHigh) {
      for (final e in entries) {
        e.value.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
      }
    } else if (sortOption.value == SortOption.priceHighToLow) {
      for (final e in entries) {
        e.value.sort((a, b) => b.displayPrice.compareTo(a.displayPrice));
      }
    } else {
      // Keep original group ordering; optionally place on-sale items first when promotionOnly is on
      if (promotionOnly.value) {
        for (final e in entries) {
          e.value.sort((a, b) {
            if (a.isOnSale == b.isOnSale) return 0;
            return a.isOnSale ? -1 : 1;
          });
        }
      }
    }

    filteredResults
      ..clear()
      ..addEntries(entries);
  }
}
