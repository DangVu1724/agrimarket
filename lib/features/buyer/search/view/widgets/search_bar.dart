import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchBar extends StatelessWidget {
  final SearchVm searchVm;
  const SearchBar({super.key, required this.searchVm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchVm.searchController,
        onChanged: (value) => searchVm.searchText.value = value,
        onSubmitted: (value) => searchVm.searchProducts(value),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm, cửa hàng...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            child: Icon(Icons.search, color: Colors.green.shade600, size: 24),
          ),
          suffixIcon: Obx(() {
            return searchVm.searchText.isNotEmpty
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.clear, size: 16, color: Colors.grey.shade700),
                    ),
                    onPressed: () {
                      searchVm.searchController.clear();
                      searchVm.searchResults.clear();
                      searchVm.searchText.value = '';
                    },
                  )
                : const SizedBox.shrink();
          }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.green.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}