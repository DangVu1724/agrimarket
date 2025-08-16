import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class FilterCuisineWidget extends StatefulWidget {
  final PanelController panelController;
  const FilterCuisineWidget({super.key, required this.panelController});

  @override
  State<FilterCuisineWidget> createState() => _FilterCuisineWidgetState();
}

class _FilterCuisineWidgetState extends State<FilterCuisineWidget> {
  final List<String> categorylist = ['Rau củ', 'Hoa quả', 'Thịt', 'Hải sản', 'Gạo', 'Sữa & Trứng'];
  late Set<String> tempSelected;

  @override
  void initState() {
    super.initState();
    final vm = Get.find<SearchVm>();
    tempSelected = Set<String>.from(vm.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ẩm thực', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: List.generate(categorylist.length, (index) {
              final label = categorylist[index];
              final selected = tempSelected.contains(label);
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    if (selected) {
                      tempSelected.remove(label);
                    } else {
                      tempSelected.add(label);
                    }
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    tempSelected.clear();
                  });
                },
                child: const Text('Xoá bộ lọc'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final vm = Get.find<SearchVm>();
                  vm.setCategories(tempSelected);
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
    );
  }
}
