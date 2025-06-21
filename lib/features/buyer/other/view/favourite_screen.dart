import 'package:agrimarket/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [CustomAppBar(backArrow: true, pageName: "Yêu thích",)],
      ),
    );
  }
}
