import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/core/widgets/social_icon.dart';
import 'package:agrimarket/data/services/auth_service.dart';
import 'package:agrimarket/features/auth/viewmodel/forgot_password_vm.dart';
import 'package:agrimarket/features/auth/viewmodel/login_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final LoginViewModel viewModel = Get.find();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Logo Section
                  _buildLogoSection(),
                  const SizedBox(height: 40),

                  // Welcome Text
                  _buildWelcomeText(),
                  const SizedBox(height: 40),

                  // Form Fields
                  _buildFormFields(viewModel),
                  const SizedBox(height: 24),

                  // Login Button
                  _buildLoginButton(viewModel),
                  const SizedBox(height: 32),

                  // Social Login Section
                  _buildSocialLoginSection(viewModel),
                  const SizedBox(height: 32),

                  // Register Link
                  _buildRegisterLink(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            // decoration: BoxDecoration(
            //   gradient: const LinearGradient(
            //     colors: [Color(0xFF00A86B), Color(0xFF00CC88)],
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //   ),
            //   borderRadius: BorderRadius.circular(20),
            //   boxShadow: [
            //     BoxShadow(
            //       color: AppColors.primary.withOpacity(0.2),
            //       blurRadius: 12,
            //       offset: const Offset(0, 6),
            //     ),
            //   ],
            // ),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.eco_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "AgriMarket",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Chào mừng trở lại!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Đăng nhập để tiếp tục trải nghiệm\nthế giới nông sản tươi ngon",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(LoginViewModel viewModel) {
    return Column(
      children: [
        // Email Field
        CustomTextFormField(
          label: "Email",
          hintText: "Nhập email của bạn",
          controller: viewModel.emailController,
          validator: (value) => viewModel.validateEmail(value ?? ""),
          maxLine: 1,

        ),
        const SizedBox(height: 20),

        // Password Field
        Obx(
              () => CustomTextFormField(
            label: "Mật khẩu",
            hintText: "Nhập mật khẩu của bạn",
            controller: viewModel.passwordController,
            obscureText: viewModel.obscureText.value,
            validator: (value) => viewModel.validatePassword(value!),
            maxLine: 1,
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.obscureText.value
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.grey.shade500,
              ),
              onPressed: viewModel.toggleText,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Remember Me & Forgot Password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Remember Me
            Row(
              children: [
                Obx(
                      () => Transform.scale(
                    scale: 0.9,
                    child: Checkbox(
                      value: viewModel.rememberMe.value,
                      onChanged: (value) => viewModel.toggleRememberMe(value ?? false),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                Text(
                  "Ghi nhớ đăng nhập",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Forgot Password
            TextButton(
              onPressed: () {
                _showForgotPasswordDialog();
              },
              child: Text(
                "Quên mật khẩu?",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        // Error Message
        Obx(() => viewModel.errorMessage.value.isNotEmpty
            ? Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red.shade600, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  viewModel.errorMessage.value,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildLoginButton(LoginViewModel viewModel) {
    return Column(
      children: [
        CustomButton(
          text: "Đăng nhập",
          onPressed: () {
            if(_formKey.currentState?.validate() ?? false) {
              viewModel.login();
            }
          },
          isLoading: viewModel.isLoading.value,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Obx(() => viewModel.isLoading.value
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                "Đăng nhập",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )),
        ),
      ],
    );
  }

  Widget _buildSocialLoginSection(LoginViewModel viewModel) {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(color: Colors.grey.shade300),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Hoặc đăng nhập bằng",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.grey.shade300),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Social Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Button
            _buildSocialButton(
              icon: "assets/images/Google.png",
              onTap: () => viewModel.socialLoginGoogle("Google"),
              color: Colors.white,
            ),
            const SizedBox(width: 16),

            // Facebook Button
            _buildSocialButton(
              icon: "assets/images/Facebook.png",
              onTap: () => viewModel.socialLogin("Facebook"),
              color: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: color == Colors.white ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Center(
          child: Image.asset(
            icon,
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.account_circle_rounded,
              color: color == Colors.white ? Colors.grey.shade600 : Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Column(
        children: [
          Text(
            "Bạn chưa có tài khoản?",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.register),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Đăng ký ngay",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final ForgotPasswordViewModel controller = Get.put(ForgotPasswordViewModel());
    final TextEditingController emailController = TextEditingController();
    final LoginViewModel viewModel = Get.find();
    final AuthService authService = Get.find<AuthService>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Quên mật khẩu",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                "Nhập email đã đăng ký để nhận liên kết đặt lại mật khẩu",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Email Field
              CustomTextFormField(
                label: "Email",
                hintText: "Nhập email của bạn",
                controller: emailController,
                validator: (value) => viewModel.validateEmail(value ?? ""),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Hủy"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: "Gửi email",
                      onPressed: () => authService.sendResetEmail(emailController.text),
                      isLoading: controller.isLoading.value,
                      backgroundColor: AppColors.primary,
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}