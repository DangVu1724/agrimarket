import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? text; 
  final Widget? child; 
  final VoidCallback? onPressed; 
  final bool isLoading; 
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final double? borderRadius;
  final double? width;
  final double? height;
  final bool outlined;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.isLoading = false,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.borderRadius,
    this.width,
    this.height,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidth = width ?? double.infinity;
    final buttonHeight = height ?? 54.0;
    final buttonPadding = padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    final buttonBorderRadius = borderRadius ?? 12.0;
    final buttonElevation = elevation ?? 4.0;
    final buttonBackgroundColor = backgroundColor ?? AppColors.primary;
    final buttonForegroundColor = foregroundColor ?? Colors.white;

    if (outlined) {
      return SizedBox(
        width: buttonWidth,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: buttonBackgroundColor,
            backgroundColor: Colors.transparent,
            side: BorderSide(
              color: buttonBackgroundColor,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonBorderRadius),
            ),
            padding: buttonPadding,
            elevation: 0,
          ),
          child: _buildChild(),
        ),
      );
    }

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBackgroundColor,
          foregroundColor: buttonForegroundColor,
          elevation: buttonElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          padding: buttonPadding,
          shadowColor: buttonBackgroundColor.withOpacity(0.3),
        ),
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );
    }

    return child ??
        Text(
          text ?? '',
          style: AppTextStyles.button.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        );
  }
}