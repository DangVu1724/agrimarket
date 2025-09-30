import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:agrimarket/features/buyer/search/view/widgets/search_bar.dart';
import 'package:agrimarket/features/buyer/search/view/widgets/search_content.dart';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:get/get.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchVm searchVm = Get.find<SearchVm>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchVm.searchController.clear();
      searchVm.searchText.value = '';
      searchVm.searchResults.clear();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tìm kiếm', style: AppTextStyles.headline),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchBar(searchVm: searchVm),
            const SizedBox(height: 16),
            Expanded(child: SearchContent(searchVm: searchVm)),
          ],
        ),
      ),
    );
  }
}
