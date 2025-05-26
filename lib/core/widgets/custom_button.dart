import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  final String? text; // Nội dung text (nếu không dùng child)
  final Widget? child; // Nội dung tùy chỉnh (icon + text)
  final VoidCallback? onPressed; // Callback khi nhấn
  final bool isLoading; // Trạng thái loading

  const CustomButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, 
      height: 50, 
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, 
          foregroundColor: Colors.white, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Bo góc
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : child ??
                Text(
                  text ?? '',
                  style: AppTextStyles.button,
                ),
      ),
    );
  }
}