import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProductFilterWidget extends StatelessWidget {
  final TextEditingController searchController;
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;

  const ProductFilterWidget({
    super.key,
    required this.searchController,
    required this.categories,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trường tìm kiếm
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên sản phẩm',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Danh mục: ', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                color: AppColors.background,
                initialValue: selectedCategory?.isEmpty ?? true ? '' : selectedCategory,
                onSelected: (value) {
                  onCategoryChanged(value == '' ? null : value);
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<String>(value: '', child: Text('Tất cả danh mục')),
                    ...categories.map((category) => PopupMenuItem<String>(value: category, child: Text(category))),
                  ];
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedCategory == null || selectedCategory == '' ? 'Tất cả danh mục' : selectedCategory!,
                      style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.filter_list, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
