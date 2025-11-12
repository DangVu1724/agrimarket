import 'package:agrimarket/app/controllers/auth_controller.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController _authController = Get.find();
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Logo Section
              _buildLogoSection(),
              const SizedBox(height: 40),
              
              // Welcome Text
              _buildWelcomeSection(),
              const SizedBox(height: 40),
              
              // Auth Buttons
              _buildAuthButtons(_authController),
              const SizedBox(height: 32),
              
              // Divider
              _buildDivider(),
              const SizedBox(height: 32),
              
              // Social Login Buttons
              _buildSocialLoginButtons(_authController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo with gradient background
        Container(
          width: 120,
          height: 120,
          // decoration: BoxDecoration(
          //   gradient: const LinearGradient(
          //     colors: [Color(0xFF00A86B), Color(0xFF00CC88)],
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight,
          //   ),
          //   borderRadius: BorderRadius.circular(24),
          //   boxShadow: [
          //     BoxShadow(
          //       color: AppColors.primary.withOpacity(0.3),
          //       blurRadius: 15,
          //       offset: const Offset(0, 8),
          //     ),
          //   ],
          // ),
          child: Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // App Name
        const Text(
          'AgriMarket',
          style: TextStyle(
            color: Color(0xFF00A86B),
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        // Tagline
        Text(
          'Kết nối nhà nông - Phục vụ người tiêu dùng',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        const Text(
          'Chào mừng đến với AgriMarket',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Khám phá thế giới nông sản tươi ngon\nvà đa dạng ngay tại đây',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthButtons(AuthController authController) {
    return Column(
      children: [
        // Login Button
        CustomButton(
          text: 'Đăng nhập',
          onPressed: () {
            Get.toNamed(AppRoutes.login);
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Register Button
        Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed(AppRoutes.register);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 0),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Đăng ký',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Hoặc tiếp tục với",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons(AuthController authController) {
    return Column(
      children: [
        // Google Button
        Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              authController.signInWithGoogle();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Google.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tiếp tục với Google',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Facebook Button
        Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF1877F2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1877F2).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              // Add Facebook login functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.facebook_rounded, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Tiếp tục với Facebook',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Guest Access
        TextButton(
          onPressed: () {
            // Handle guest access
          },
          child: RichText(
            text: TextSpan(
              text: 'Tiếp tục với tư cách ',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              children: const [
                TextSpan(
                  text: 'khách',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}