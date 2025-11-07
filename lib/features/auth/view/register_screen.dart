import 'package:agrimarket/app/controllers/auth_controller.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/core/widgets/custom_button.dart';
import 'package:agrimarket/core/widgets/custom_text_form_field.dart';
import 'package:agrimarket/features/auth/viewmodel/login_vm.dart';
import 'package:agrimarket/features/auth/viewmodel/register_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final RegisterViewModel _viewModel = Get.find<RegisterViewModel>();
    final LoginViewModel loginViewModel = Get.find();

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
                  _buildFormFields(_viewModel),
                  const SizedBox(height: 24),

                  // Terms Checkbox
                  _buildTermsCheckbox(_viewModel),
                  const SizedBox(height: 24),

                  // Register Button
                  _buildRegisterButton(_viewModel),
                  const SizedBox(height: 32),

                  // Social Login Section
                  _buildSocialLoginSection(loginViewModel),
                  const SizedBox(height: 32),

                  // Login Link
                  _buildLoginLink(),
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
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00A86B), Color(0xFF00CC88)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 60,
                height: 60,
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
          "Tạo tài khoản mới",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Đăng ký để khám phá thế giới nông sản\ntươi ngon và đa dạng",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(RegisterViewModel viewModel) {
    return Column(
      children: [
        // Full Name Field
        CustomTextFormField(
          label: "Họ và tên",
          hintText: "Nhập họ và tên của bạn",
          controller: viewModel.fullNameController,
          validator: (value) => viewModel.validateFullName(value ?? ""),
          maxLine: 1,
        ),
        const SizedBox(height: 16),

        // Email Field
        CustomTextFormField(
          label: "Email",
          hintText: "Nhập email của bạn",
          controller: viewModel.emailController,
          keyboard: TextInputType.emailAddress,
          validator: (value) => viewModel.validateEmail(value ?? ""),
          maxLine: 1,
        ),
        const SizedBox(height: 16),

        // Phone Field
        CustomTextFormField(
          label: "Số điện thoại",
          hintText: "Nhập số điện thoại của bạn",
          controller: viewModel.phoneController,
          keyboard: TextInputType.phone,
          validator: (value) => viewModel.validatePhoneNumber(value ?? ""),
          maxLine: 1,
        ),
        const SizedBox(height: 16),

        // Password Field
        Obx(
              () => CustomTextFormField(
            label: "Mật khẩu",
            hintText: "Nhập mật khẩu của bạn",
            controller: viewModel.passwordController,
            obscureText: viewModel.obscurePassword.value,
            validator: viewModel.validatePassword,
            keyboard: TextInputType.visiblePassword,
            maxLine: 1,
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.obscurePassword.value
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.grey.shade500,
              ),
              onPressed: () {
                viewModel.obscurePassword.value = !viewModel.obscurePassword.value;
              },
            ),
          ),
        ),

        // Error Message
        Obx(() => viewModel.errorMessage.value.isNotEmpty
            ? Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16),
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

  Widget _buildTermsCheckbox(RegisterViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
                () => Transform.scale(
              scale: 0.9,
              child: Checkbox(
                value: viewModel.agreeTerms.value,
                onChanged: (value) {
                  viewModel.agreeTerms.value = value ?? false;
                },
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Điều khoản & Chính sách",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tôi đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của AgriMarket",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigate to terms of service
                      },
                      child: Text(
                        "Điều khoản dịch vụ",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        // Navigate to privacy policy
                      },
                      child: Text(
                        "Chính sách bảo mật",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(RegisterViewModel viewModel) {
    return Column(
      children: [
        CustomButton(
          text: "Đăng ký",
          onPressed: () {
            if(_formKey.currentState?.validate() ?? false){
              viewModel.signUp();
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
              Icon(Icons.person_add_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                "Tạo tài khoản",
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

  Widget _buildSocialLoginSection(LoginViewModel loginViewModel) {
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
                "Hoặc đăng ký bằng",
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
              onTap: () => loginViewModel.socialLoginGoogle("Google"),
              color: Colors.white,
            ),
            const SizedBox(width: 16),

            // Facebook Button
            _buildSocialButton(
              icon: "assets/images/Facebook.png",
              onTap: () => loginViewModel.socialLogin("Facebook"),
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

  Widget _buildLoginLink() {
    return Center(
      child: Column(
        children: [
          Text(
            "Đã có tài khoản?",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Get.toNamed('/login'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Đăng nhập ngay",
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
}