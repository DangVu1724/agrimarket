import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboard;
  final ValueChanged<String>? onChanged;
  final AutovalidateMode? autovalidateMode;
  final int? maxLine;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboard,
    this.onChanged,
    this.maxLine,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
          keyboardType: keyboard,
          onChanged: onChanged,
          autovalidateMode: autovalidateMode,
          maxLines: obscureText ? 1 : maxLine,
        ),
      ],
    );
  }
}
