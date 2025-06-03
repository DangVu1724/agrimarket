import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrimarket/features/seller/viewmodel/seller_home_vm.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SellerHomeVm vm = Get.find<SellerHomeVm>();

    return Scaffold(
    body: Obx(
      () => SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text('Chào mừng, ${vm.storeName.value}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    
                  ),
                  
                  Text(' ${vm.storeState.value}',
                    style: TextStyle(
                      fontSize: 14,
                      color: vm.storeStateColor.value, 
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}