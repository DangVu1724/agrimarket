import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/custom_button.dart';
import 'package:agrimarket/features/auth/viewmodel/email_verify_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmailVerificationScreen extends StatelessWidget {
  final EmailVerificationViewModel vm = Get.put(EmailVerificationViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Xác minh Email',style: AppTextStyles.headline,),centerTitle: true,backgroundColor: Colors.white,),
      body: Obx(() {
        return Center(
          child: vm.isLoading.value
              ? CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.email, size: 80, color: Colors.blue),
                      SizedBox(height: 20),
                      Text(
                        'Chúng tôi đã gửi liên kết xác minh đến email của bạn.\nVui lòng xác minh trước khi tiếp tục.',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      CustomButton(
                        text: 'Gửi lại email xác minh',
                        onPressed: () {
                          vm.resendEmailVerification();
                        },
                      ),
                    ],
                  ),
                ),
        );
      }),
    );
  }
}
