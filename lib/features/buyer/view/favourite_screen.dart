import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Yêu thích'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Text(
          'Danh sách sản phẩm yêu thích sẽ hiển thị ở đây.',
          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
