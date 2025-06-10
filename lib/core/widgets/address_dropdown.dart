import 'package:flutter/material.dart';
import 'package:agrimarket/app/theme/app_colors.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String labelText;
  final T? value;
  final List<Map<String, dynamic>> items;
  final bool? isLoading;
  final bool isEnabled;
  final String? hintText;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final String valueKey;
  final String displayKey;

  const CustomDropdownField({
    Key? key,
    required this.labelText,
    required this.value,
    required this.items,
     this.isLoading,
    this.isEnabled = true,
    this.hintText,
    this.onChanged,
    this.validator,
    this.valueKey = 'code',
    this.displayKey = 'name',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DropdownButtonFormField<T>(
          decoration: InputDecoration(
            fillColor: AppColors.background,
            labelText: labelText,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          value: value,
          dropdownColor: AppColors.background,
          items: items.isNotEmpty && isEnabled
              ? items.map<DropdownMenuItem<T>>((item) {
                final code = item[valueKey].toString();
                  return DropdownMenuItem<T>(
                    value: code as T,
                    child: Text(
                      item[displayKey] as String,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList()
              : [],
          onChanged: (isLoading ?? false) || !isEnabled ? null : onChanged,
          hint: Text(
            (isLoading ?? false)
                ? 'Đang tải ${labelText.toLowerCase()}...'
                : hintText ?? 'Chọn ${labelText.toLowerCase()}',
          ),
          validator: validator ??
              (value) => value == null ? 'Vui lòng chọn ${labelText.toLowerCase()}' : null,
          isExpanded: true,
          menuMaxHeight: 300,
        ),
        if (isLoading ?? false)
          const Positioned(
            right: 10,
            top: 15,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}