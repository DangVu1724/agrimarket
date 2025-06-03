import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/core/widgets/custom_text_form_field.dart';
import 'package:agrimarket/features/buyer/viewmodel/user_vm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/instance_manager.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserVm vm = Get.find<UserVm>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.toNamed(AppRoutes.buyerHome),
        ),
        title: const Text('Thông tin cá nhân'),
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: vm.formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextFormField(
                    label: 'Họ và tên',
                    hintText: 'Nhập họ và tên',
                    controller: vm.nameController,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
                  ),
                  const SizedBox(height: 20),

                  CustomTextFormField(
                    label: 'Số điện thoại',
                    hintText: 'Nhập số điện thoại',
                    controller: vm.phoneController,
                    keyboard: TextInputType.phone,
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Vui lòng nhập số điện thoại'
                                : null,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (vm.formKey.currentState?.validate() ?? false) {
                  vm.updateProfile(
                    newName: vm.nameController.text.trim(),
                    newPhone: vm.phoneController.text.trim(),
                  );
                }
              },
              child: const Text('Cập nhật thông tin'),
            ),
          ],
        ),
      ),
    );
  }
}
