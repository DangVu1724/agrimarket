import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class SellerChatScreen extends StatelessWidget {
  const SellerChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Trò chuyện',style: AppTextStyles.headline,),
        centerTitle: true,
      ),
    );
  }
}