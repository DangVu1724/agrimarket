import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class OrderlistScreen extends StatelessWidget {
  const OrderlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Danh sách đơn hàng',style: AppTextStyles.headline,),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Chức năng đang được phát triển',
          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
        ),
      ),
    );
  }
}