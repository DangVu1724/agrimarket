import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/buyer/search/view/widgets/slide_panel.dart';
import 'package:agrimarket/features/buyer/search/viewmodel/filter_vm.dart';
import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:agrimarket/features/buyer/search/view/widgets/category_list.dart';
import 'package:agrimarket/features/buyer/search/view/widgets/history_list.dart';
import 'package:agrimarket/features/buyer/search/view/widgets/search_result_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchContent extends StatelessWidget {
  final SearchVm searchVm;
  final FilterVm filterVm;
  const SearchContent({
    super.key,
    required this.searchVm,
    required this.filterVm,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var results = searchVm.searchResults;
      final history = searchVm.history;
      final keyword = searchVm.searchText.value;
      final isSearching = searchVm.isSearching.value;

      if (isSearching) {
        return const Center(child: CircularProgressIndicator());
      }

      if (results.isNotEmpty) {
        filterVm.searchResults.value = searchVm.searchResults;
        filterVm.applyFilters();
        results = filterVm.filterResults;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Obx(() {
                    return IconButton(
                      onPressed: () {
                        filterVm.removeKeyword("price");
                        filterVm.addKeyword("sold");
                        filterVm.setUpperSold();
                      },
                      icon: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  filterVm.filterKeywords.contains("sold")
                                      ? Colors.green
                                      : Colors.white,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Lượt mua"),
                            Icon(
                              filterVm.upperSold.value
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 14,
                              color:
                                  filterVm.filterKeywords.contains("sold")
                                      ? AppColors.primary
                                      : Colors.grey[500],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                Container(
                  width: 1,
                  height: 25,
                  color: Colors.grey,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: Obx(() {
                    return IconButton(
                      onPressed: () {
                        filterVm.removeKeyword("sold");
                        filterVm.addKeyword("price");
                        filterVm.setUpperPrice();
                      },
                      icon: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  filterVm.filterKeywords.contains("price")
                                      ? Colors.green
                                      : Colors.white,
                            ),
                          ),
                        ),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Giá"),
                            Icon(
                              filterVm.upperPrice.value
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 14,
                              color:
                                  filterVm.filterKeywords.contains("price")
                                      ? AppColors.primary
                                      : Colors.grey[500],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                Container(
                  width: 1,
                  height: 25,
                  color: Colors.grey,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () => showSlidePanel(context, filterVm),
                    icon: const Text("Lọc"),
                  ),
                ),
              ],
            ),

            Expanded(
              child: GridView.builder(
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
              ),
            ),
          ],
        );
      }

      if (keyword.isNotEmpty && results.isEmpty && searchVm.hasSearched.value) {
        return Column(
          children: [
            const CategoryList(),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Không có sản phẩm bạn muốn tìm',
                style: AppTextStyles.headline.copyWith(fontSize: 16),
              ),
            ),
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
        children: const [
          CategoryList(),
          SizedBox(height: 20),
          Center(child: Text('Hãy nhập từ khoá để tìm kiếm')),
        ],
      );
    });
  }
}
