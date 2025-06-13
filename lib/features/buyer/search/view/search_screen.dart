import 'package:agrimarket/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            child: Container(
              padding: EdgeInsets.all(10),
              
            ),
          ),
        ],
      ),
    );
  }
}
