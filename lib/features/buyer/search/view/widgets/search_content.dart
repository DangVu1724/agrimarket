import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:agrimarket/features/buyer/search/view/widgets/category_list.dart';
import 'package:agrimarket/features/buyer/search/view/widgets/history_list.dart';
import 'package:agrimarket/features/buyer/search/view/widgets/search_result_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchContent extends StatelessWidget {
  final SearchVm searchVm;
  const SearchContent({super.key, required this.searchVm});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final results = searchVm.searchResults;
      final history = searchVm.history;
      final keyword = searchVm.searchText.value;
      final isSearching = searchVm.isSearching.value;

      if (isSearching) {
        return const Center(child: CircularProgressIndicator());
      }

      if (results.isNotEmpty) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.6,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return SearchResultItem(result: results[index]);
          },
        );
      }

      if (keyword.isNotEmpty && results.isEmpty && searchVm.hasSearched.value) {
        return Column(
          children: [
            const CategoryList(),
            const SizedBox(height: 10),
            Center(child: Text('Không có sản phẩm bạn muốn tìm', style: AppTextStyles.headline.copyWith(fontSize: 16))),
          ],
        );
      }

      if (history.isNotEmpty && keyword.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CategoryList(),
            const SizedBox(height: 20),
            const SizedBox(height: 8),
            Expanded(child: HistoryList(history: history, searchVm: searchVm)),
          ],
        );
      }

      return Column(
        children: const [CategoryList(), SizedBox(height: 20), Center(child: Text('Hãy nhập từ khoá để tìm kiếm'))],
      );
    });
  }
}
