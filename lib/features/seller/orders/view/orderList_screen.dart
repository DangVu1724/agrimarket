import 'package:flutter/material.dart';

class OrderlistScreen extends StatelessWidget {
  const OrderlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Danh sách đơn hàng'),
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