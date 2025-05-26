import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static final body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  static final button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static final caption = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}