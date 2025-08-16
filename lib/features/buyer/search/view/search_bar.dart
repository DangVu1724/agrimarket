import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SearchBarWidget extends StatelessWidget {
  final SearchVm searchVm;
  final PanelController panelController;
  const SearchBarWidget({super.key, required this.searchVm, required this.panelController});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchVm.searchController,
      onChanged: searchVm.onQueryChanged,
      onSubmitted: (value) => searchVm.searchProducts(value),
      decoration: InputDecoration(
        hintText: 'Bạn muốn mua gì?',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Obx(() {
          return searchVm.searchText.value.isNotEmpty
              ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () async {
                  searchVm.searchController.clear();
                  searchVm.clearResults();
                  searchVm.searchText.value = '';
                  searchVm.clearFilter();
                  try {
                    if (panelController.isAttached && panelController.isPanelOpen) {
                      await panelController.close();
                    }
                  } catch (e) {
                    print('PanelController chưa attach: $e');
                  }
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
