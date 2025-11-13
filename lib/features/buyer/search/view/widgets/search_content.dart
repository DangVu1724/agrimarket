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

  const SearchContent({super.key, required this.searchVm, required this.filterVm});

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

      // Nếu có kết quả tìm kiếm
      if (results.isNotEmpty) {
        // Gán dữ liệu tìm kiếm vào filterVm
        filterVm.searchResults.value = searchVm.searchResults;
        filterVm.applyFilters();
        results = filterVm.filterResults;

        return Column(
          children: [
            // Thanh sort / lọc
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Obx(() {
                    final isActive = filterVm.filterKeywords.contains("sold");
                    return InkWell(
                      onTap: () {
                        filterVm.removeKeyword("price");
                        filterVm.addKeyword("sold");
                        filterVm.setUpperSold();
                        filterVm.applyFilters();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: isActive ? AppColors.primary : Colors.transparent, width: 2),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Lượt mua"),
                            Icon(
                              filterVm.upperSold.value ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 14,
                              color: isActive ? AppColors.primary : Colors.grey[500],
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
                  color: Colors.grey[400],
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),

                Expanded(
                  child: Obx(() {
                    final isActive = filterVm.filterKeywords.contains("price");
                    return InkWell(
                      onTap: () {
                        filterVm.removeKeyword("sold");
                        filterVm.addKeyword("price");
                        filterVm.setUpperPrice();
                        filterVm.applyFilters();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: isActive ? AppColors.primary : Colors.transparent, width: 2),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Giá"),
                            Icon(
                              filterVm.upperPrice.value ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 14,
                              color: isActive ? AppColors.primary : Colors.grey[500],
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
                  color: Colors.grey[400],
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),

                Expanded(
                  child: TextButton.icon(
                    onPressed: () => showSlidePanel(context, filterVm),
                    icon: const Icon(Icons.filter_alt, color: Colors.green),
                    label: const Text("Lọc", style: TextStyle(color: Colors.green)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Danh sách kết quả
            Expanded(
              child:
                  results.isEmpty
                      ? const Center(
                        child: Text("Không có sản phẩm phù hợp với bộ lọc", style: TextStyle(color: Colors.grey)),
                      )
                      : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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

      // Khi đã tìm kiếm nhưng không có kết quả
      if (keyword.isNotEmpty && searchVm.hasSearched.value && results.isEmpty) {
        return Column(
          children: [
            const CategoryList(),
            const SizedBox(height: 10),
            Center(child: Text('Không có sản phẩm bạn muốn tìm', style: AppTextStyles.headline.copyWith(fontSize: 16))),
          ],
        );
      }

      // Khi đang gõ từ khóa nhưng chưa bấm tìm kiếm
      if (keyword.isNotEmpty && !searchVm.hasSearched.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CategoryList(),
            const SizedBox(height: 20),
            Expanded(child: HistoryList(history: history, searchVm: searchVm)),
          ],
        );
      }

      // Hiển thị lịch sử tìm kiếm
      if (history.isNotEmpty && keyword.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CategoryList(),
            const SizedBox(height: 20),
            Expanded(child: HistoryList(history: history, searchVm: searchVm)),
          ],
        );
      }

      // Mặc định: chưa nhập từ khoá
      return Column(
        children: const [CategoryList(), SizedBox(height: 20), Center(child: Text('Hãy nhập từ khoá để tìm kiếm'))],
      );
    });
  }
}
