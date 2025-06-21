import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Tìm kiếm',style: AppTextStyles.headline,),
        centerTitle: true,
      ),
      // body: Obx(() {
      //   return SingleChildScrollView(
      //     child: Column(

      //     ),
      //   );
      // })
    );
  }
}