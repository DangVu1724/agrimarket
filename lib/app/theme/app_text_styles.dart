import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final headline = GoogleFonts.merriweather(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final body = GoogleFonts.beVietnamPro(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static final button = GoogleFonts.beVietnamPro(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static final caption = GoogleFonts.beVietnamPro(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}
