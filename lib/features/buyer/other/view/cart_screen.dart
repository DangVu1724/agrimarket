import 'package:agrimarket/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [CustomAppBar(backArrow: true, pageName: "Giỏ hàng",)],
      ),
    );
  }
}
