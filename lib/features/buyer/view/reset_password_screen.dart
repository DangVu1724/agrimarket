import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../viewmodel/reset_password_vm.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ResetPasswordViewModel resetPassVm = Get.find<ResetPasswordViewModel>();
  
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Đổi mật khẩu mới', style: AppTextStyles.headline),
        backgroundColor: AppColors.background,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: resetPassVm.formKeyResetPass,
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextFormField(
                  label: 'Mật khẩu mới',
                  hintText: 'Nhập mật khẩu mới',
                  obscureText: true, controller: resetPassVm.newPasswordController,
                  onChanged: (value) {
                    resetPassVm.newPassword.value = value;
                  },
                  validator: resetPassVm.validatePassword,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  label: 'Xác nhận mật khẩu mới',
                  hintText: 'Xác nhận mật khẩu',
                  obscureText: true, controller: resetPassVm.confirmPasswordController,
                  validator: resetPassVm.validateConfirmPassword,
                  onChanged: (value) {
                    resetPassVm.confirmPassword.value = value;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Đổi mật khẩu',
                  onPressed: resetPassVm.updatePassword,
                  isLoading: resetPassVm.isLoading.value,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}