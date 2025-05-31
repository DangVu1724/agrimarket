import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

Widget socialIcon(String assetPath) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Color(0xFFD6D6D6)),
      ),
      child: Image.asset(
        assetPath,
        width: 40,
        height: 40,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.error,
          size: 40,
          color: AppColors.primary,
        ),
      ),
    );
  }