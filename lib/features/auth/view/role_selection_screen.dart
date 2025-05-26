import 'package:agrimarket/app/controllers/auth_controller.dart';
import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class RoleSelectionScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  RoleSelectionScreen({super.key});

  void _selectRole(String role) async {
    await _authController.updateUserRole(role);

    if (role == 'buyer') {
      Get.offNamed(AppRoutes.addAddress);
    } else if (role == 'seller') {
      Get.offNamed(AppRoutes.sellerHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Image.asset('assets/images/logo.png', width: 150, height: 150),
            const SizedBox(height: 20),
            Text(
              'Bạn muốn đăng ký với vai trò nào?',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: const Text('Người Mua',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primary, 
              ),
              onPressed: () => _selectRole('buyer'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.sell, color: Colors.white),
              label: const Text('Người bán',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primary
              ),
              onPressed: () => _selectRole('seller'),
            ),
          ],
        ),
      ),
    );
  }
}
