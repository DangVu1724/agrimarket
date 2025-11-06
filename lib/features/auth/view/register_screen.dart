import 'package:agrimarket/app/controllers/auth_controller.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/core/widgets/custom_text_form_field.dart';
import 'package:agrimarket/core/widgets/social_icon.dart';
import 'package:agrimarket/features/auth/viewmodel/login_vm.dart';
import 'package:agrimarket/features/auth/viewmodel/register_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterViewModel _viewModel = Get.find<RegisterViewModel>();
    final AuthController _authController = Get.find();
    final LoginViewModel loginViewModel = Get.find();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _viewModel.formKeyRes,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Center(child: Image.asset('assets/images/logo.png', width: 120, height: 120)),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text("ĐĂNG KÝ TÀI KHOẢN", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Vui lòng đăng ký tài khoản của bạn để bắt đầu khám phá AgriMarket",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Color(0xFF878787)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),
                  CustomTextFormField(
                    label: "Họ và tên",
                    hintText: "Nhập họ và tên",
                    controller: _viewModel.fullNameController,
                    validator: (value) => _viewModel.validateFullName(value ?? ""),
                    maxLine: 1,
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    label: "Email",
                    hintText: "Nhập email",
                    controller: _viewModel.emailController,
                    keyboard: TextInputType.emailAddress,
                    validator: (value) => _viewModel.validateEmail(value ?? ""),
                    maxLine: 1,
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    label: "Số điện thoại",
                    hintText: "Nhập số điện thoại",
                    controller: _viewModel.phoneController,
                    keyboard: TextInputType.phone,
                    validator: (value) => _viewModel.validatePhoneNumber(value ?? ""),
                    maxLine: 1,
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => CustomTextFormField(
                      label: 'Mật khẩu',
                      hintText: 'Mật khẩu',
                      maxLine: 1,
                      controller: _viewModel.passwordController,
                      obscureText: _viewModel.obscurePassword.value,
                      validator: _viewModel.validatePassword,
                      keyboard: TextInputType.visiblePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_viewModel.obscurePassword.value ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          _viewModel.obscurePassword.value = !_viewModel.obscurePassword.value;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Obx(
                    () => Row(
                      children: [
                        Checkbox(
                          value: _viewModel.agreeTerms.value,
                          onChanged: (value) {
                            _viewModel.agreeTerms.value = value ?? false;
                          },
                          activeColor: const Color.fromRGBO(0, 153, 68, 1),
                        ),
                        const Expanded(
                          child: Text(
                            "Tôi đồng ý với Điều khoản dịch vụ và Chính sách bảo mật",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () =>
                        _viewModel.errorMessage.value.isNotEmpty
                            ? Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                _viewModel.errorMessage.value,
                                style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(0, 153, 68, 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: _viewModel.isLoading.value ? null : () => _viewModel.signUp(),
                        child:
                            _viewModel.isLoading.value
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Đăng ký", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: const [
                      Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("Hoặc đăng ký bằng", style: TextStyle(color: Color(0xFF878787))),
                      ),
                      Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => loginViewModel.socialLoginGoogle("Google"),
                        child: socialIcon("assets/images/Google.png"),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => loginViewModel.socialLogin("Facebook"),
                        child: socialIcon("assets/images/Facebook.png"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed('/login');
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: "Bạn đã có tài khoản? ",
                            children: [
                              TextSpan(
                                text: "Đăng nhập",
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
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
}
