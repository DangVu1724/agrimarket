import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchBar extends StatelessWidget {
  final SearchVm searchVm;
  const SearchBar({super.key, required this.searchVm});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchVm.searchController,
      onSubmitted: (value) => searchVm.searchProducts(value),
      decoration: InputDecoration(
        hintText: 'Bạn muốn mua gì?',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Obx(() {
          return searchVm.searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchVm.searchController.clear();
                    searchVm.searchResults.clear();
                    searchVm.searchText.value = '';
                  },
                )
              : const SizedBox.shrink();
        }),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
