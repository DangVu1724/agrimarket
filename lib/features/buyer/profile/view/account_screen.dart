import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/core/widgets/custom_text_form_field.dart';
import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/instance_manager.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final UserVm vm = Get.find<UserVm>();
  late TextEditingController nameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: vm.userName.value);
    phoneController = TextEditingController(text: vm.userPhone.value);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text('Thông tin cá nhân'),
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: vm.userformKey,
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
                    controller: nameController,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
                  ),
                  const SizedBox(height: 20),

                  CustomTextFormField(
                    label: 'Số điện thoại',
                    hintText: 'Nhập số điện thoại',
                    controller: phoneController,
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
                if (vm.userformKey.currentState?.validate() ?? false) {
                  vm.updateProfile(
                    newName: nameController.text.trim(),
                    newPhone: phoneController.text.trim(),
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
