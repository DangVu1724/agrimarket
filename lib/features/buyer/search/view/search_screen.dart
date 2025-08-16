import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/buyer/search/view/search_bar.dart';
import 'package:agrimarket/features/buyer/search/view/search_result_list.dart';
import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});
  final PanelController panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    final SearchVm searchVm = Get.find<SearchVm>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Reset search UI state when entering the screen
      searchVm.searchController.clear();
      searchVm.searchText.value = '';
      searchVm.clearResults();
      searchVm.clearFilter();
      if (panelController.isAttached) {
        await panelController.close();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tìm kiếm', style: AppTextStyles.headline),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SearchBarWidget(searchVm: searchVm, panelController: panelController),
          ),
          const SizedBox(height: 16),
          // Child already manages its own Expanded
          SearchList(searchVm: searchVm, panelController: panelController),
        ],
      ),
    );
  }
}
