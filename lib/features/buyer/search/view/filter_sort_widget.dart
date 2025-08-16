import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class FilterSortWidget extends StatefulWidget {
  final PanelController panelController;
  const FilterSortWidget({super.key, required this.panelController});

  @override
  State<FilterSortWidget> createState() => _FilterSortWidgetState();
}

class _FilterSortWidgetState extends State<FilterSortWidget> {
  final List<String> options = [
    'Được đề xuất',
    'Giá thấp đến cao',
    'Giá cao đến thấp',
    'Phổ biến',
    'Đánh giá cao',
    'Gần tôi',
  ];

  int selectedIndex = 0;
  int? tempIndex;

  @override
  void initState() {
    super.initState();
    final vm = Get.find<SearchVm>();
    selectedIndex = _mapSortOptionToIndex(vm.sortOption.value);
    tempIndex = selectedIndex;
  }

  int _mapSortOptionToIndex(SortOption option) {
    switch (option) {
      case SortOption.recommended:
        return 0;
      case SortOption.priceLowToHigh:
        return 1;
      case SortOption.priceHighToLow:
        return 2;
      case SortOption.popular:
        return 3;
      case SortOption.ratingHigh:
        return 4;
      case SortOption.distance:
        return 5;
      case SortOption.newest:
        return 0; // map to recommended by default; 'Newest' is controlled by chip outside
    }
  }

  SortOption _mapIndexToSortOption(int index) {
    switch (index) {
      case 1:
        return SortOption.priceLowToHigh;
      case 2:
        return SortOption.priceHighToLow;
      case 3:
        return SortOption.popular;
      case 4:
        return SortOption.ratingHigh;
      case 5:
        return SortOption.distance;
      case 0:
      default:
        return SortOption.recommended;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Lọc theo', style: AppTextStyles.body),
            Column(
              children: List.generate(options.length, (index) {
                final isSelected = tempIndex == null ? selectedIndex == index : tempIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      tempIndex = index;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            options[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              }),
            ),
            if (tempIndex != null && tempIndex != selectedIndex)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        tempIndex = selectedIndex; // quay lại ban đầu
                      });
                    },
                    child: const Text('Huỷ'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final vm = Get.find<SearchVm>();
                      setState(() {
                        selectedIndex = tempIndex!;
                        tempIndex = null;
                      });
                      vm.setSortOption(_mapIndexToSortOption(selectedIndex));
                      try {
                        if (widget.panelController.isAttached && widget.panelController.isPanelOpen) {
                          await widget.panelController.close();
                        }
                      } catch (e) {
                        print('PanelController chưa attach: $e');
                      }
                    },
                    child: const Text('Áp dụng'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
