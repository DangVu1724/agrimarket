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
    final ResetPasswordViewModel controller = Get.put(ResetPasswordViewModel());
    

    return Scaffold(
      appBar: AppBar(
        title: Text('Đổi mật khẩu mới', style: AppTextStyles.headline),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFormField(
                label: 'Mật khẩu mới',
                hintText: 'Nhập mật khẩu mới',
                obscureText: true, controller: controller.newPasswordController,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Xác nhận mật khẩu mới',
                hintText: 'Xác nhận mật khẩu',
                obscureText: true, controller: controller.confirmPasswordController,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Đổi mật khẩu',
                onPressed: controller.updatePassword,
                isLoading: controller.isLoading.value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}