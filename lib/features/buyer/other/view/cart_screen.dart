import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 0, // Replace with your cart item count
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'), // Replace with your cart item details
                  subtitle: Text('Description of item $index'),
                  trailing: Text('\$${(index + 1) * 10}'), // Replace with your item price
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle checkout action
              },
              child: const Text('Thanh toán'),
            ),
          ),
        ],
      ),
    );
  }
}
