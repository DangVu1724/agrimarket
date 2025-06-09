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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),
          // Dropdown chọn danh mục
          DropdownButtonFormField<String>(
            value: selectedCategory?.isEmpty ?? true ? null : selectedCategory,
            hint: const Text('Chọn danh mục'),
            items: [
              const DropdownMenuItem<String>(
                value: '',
                child: Text('Tất cả danh mục'),
              ),
              ...categories.map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  )),
            ],
            onChanged: onCategoryChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            isExpanded: true,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}