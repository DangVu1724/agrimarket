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


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginViewModel viewModel = Get.find();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 150,
                      height: 150,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.eco,
                        size: 150,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      "Đăng nhập vào tài khoản của bạn",
                      style: AppTextStyles.headline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Vui lòng đăng nhập để tiếp tục",
                      style: AppTextStyles.caption,
                    ),
                  ),
                  const SizedBox(height: 52),
                  CustomTextFormField(
                    label: "Email Address",
                    hintText: "Enter Email",
                    controller: viewModel.emailController,
                    validator: (value) => viewModel.validateEmail(value ?? "")
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => CustomTextFormField(
                      label: "Password",
                      hintText: "Password",
                      controller: viewModel.passwordController,
                      obscureText: viewModel.obscureText.value,
                      validator: (value) => viewModel.validatePassword(value!),
                      suffixIcon: IconButton(
                        icon: Icon(
                          viewModel.obscureText.value ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: viewModel.toggleText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Obx(
                            () => Checkbox(
                              value: viewModel.rememberMe.value,
                              onChanged: (value) => viewModel.toggleRememberMe(value ?? false),
                              activeColor: AppColors.primary,
                            ),
                          ),
                          Text(
                            "Remember me",
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          showForgotPasswordDialog();
                        },
                        child: Text(
                          "Quên mật khẩu?",
                          style: AppTextStyles.body.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    text: "Đăng nhập",
                    onPressed: viewModel.login,
                    isLoading: viewModel.isLoading.value,
                  ),
                  const SizedBox(height: 34),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.textSecondary)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Hoặc đăng nhập bằng",
                          style: AppTextStyles.caption,
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => viewModel.socialLoginGoogle("Google"),
                        child: socialIcon("assets/images/Google.png"),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => viewModel.socialLogin("Facebook"),
                        child: socialIcon("assets/images/Facebook.png"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.register),
                      child: Text.rich(
                        TextSpan(
                          text: "Bạn chưa có tài khoản? ",
                          style: AppTextStyles.body,
                          children: [
                            TextSpan(
                              text: "Đăng ký ngay",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



 void showForgotPasswordDialog() {
  final ForgotPasswordViewModel controller = Get.put(ForgotPasswordViewModel());
  final TextEditingController emailController = TextEditingController();
  final LoginViewModel viewModel = Get.find();
  final AuthService authService = Get.find<AuthService>();


  Get.defaultDialog(
    title: 'Quên mật khẩu',
    titleStyle: AppTextStyles.headline,
    content: Obx(
      () => Column(
        children: [
          CustomTextFormField(
                    label: "Email",
                    hintText: "Enter Email",
                    controller: emailController,
                    validator: (value) => viewModel.validateEmail(value ?? "")
                  ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Gửi Email',
            onPressed: () => authService.sendResetEmail(emailController.text),
            isLoading: controller.isLoading.value,
          ),
          const SizedBox(height: 10),
          Text(
            'Vui lòng nhập email đã đăng ký để nhận liên kết đặt lại mật khẩu.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
    textCancel: 'Hủy',
    cancelTextColor: AppColors.primary,
  );
}
}