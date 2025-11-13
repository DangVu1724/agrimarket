import 'package:agrimarket/features/buyer/search/viewmodel/filter_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlidePanel extends StatelessWidget {
  const SlidePanel({super.key, required this.filterVm});
  final FilterVm filterVm;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.7;
    final height = MediaQuery.of(context).size.height * 0.8;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(20))),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop())],
                ),
                const Text("Lọc sản phẩm", style: TextStyle(fontSize: 20)),
                const Divider(),

                // Lọc khoảng giá
                // Thay cho Row TextField
                const Text("Khoảng giá"),
                const SizedBox(height: 10),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    children: List.generate(filterVm.priceOptions.length, (index) {
                      final option = filterVm.priceOptions[index];
                      final label =
                          option["max"] == double.infinity
                              ? "Trên ${option['min']!.toInt() / 1000}k"
                              : "${option['min']!.toInt() / 1000}k - ${option['max']!.toInt() / 1000}k";
                      final isSelected = filterVm.selectedPriceIndex.value == index;
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: Colors.green[200],
                        onSelected: (_) {
                          filterVm.selectedPriceIndex.value = isSelected ? -1 : index; // bấm lại bỏ chọn
                          if (isSelected) {
                            filterVm.from.value = 0.0;
                            filterVm.to.value = double.infinity;
                          } else {
                            filterVm.from.value = option["min"]!;
                            filterVm.to.value = option["max"]!;
                          }
                        },
                      );
                    }),
                  ),
                ),
                const Divider(),

                // Lọc theo danh mục
                const Text("Danh mục"),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 3.6,
                    ),
                    itemCount: filterVm.categories.length,
                    itemBuilder: (context, index) {
                      final category = filterVm.categories[index];

                      return Obx(() {
                        final isSelected = filterVm.category.value == category;
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            color: isSelected ? Colors.lightGreenAccent.shade100 : Colors.white,
                            border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300),
                          ),
                          child: TextButton(
                            child: Text(
                              category,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.green),
                            ),
                            onPressed: () {
                              filterVm.category.value = category;
                            },
                          ),
                        );
                      });
                    },
                  ),
                ),

                const Divider(),
                const Text("Đánh giá cửa hàng"),
                const SizedBox(height: 8),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    children:
                        filterVm.ratingOptions.map((rating) {
                          final isSelected = filterVm.rating.value == rating;
                          return ChoiceChip(
                            label: Text("$rating ★"),
                            selected: isSelected,
                            selectedColor: Colors.green[200],
                            onSelected: (_) {
                              filterVm.rating.value = isSelected ? 0 : rating; // bỏ chọn nếu bấm lại
                            },
                          );
                        }).toList(),
                  ),
                ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[300]),
                      onPressed: () {
                        filterVm.resetFilters();
                        Navigator.of(context).pop();
                      },
                      child: const Text("Xóa lọc", style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[500]),
                      onPressed: () {
                        filterVm.applyFilters();
                        Navigator.of(context).pop();
                      },
                      child: const Text("Áp dụng", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showSlidePanel(BuildContext context, FilterVm filterVm) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // giữ hiệu ứng overlay
    builder:
        (context) => Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(20))),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.8,
              child: SlidePanel(filterVm: filterVm),
            ),
          ),
        ),
  );
}
