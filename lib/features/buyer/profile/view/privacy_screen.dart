import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Chính sách quyền riêng tư',style: AppTextStyles.headline,),
          centerTitle: true,
          backgroundColor: Colors.white,
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'Chúng tôi cam kết bảo vệ quyền riêng tư của bạn. '
            'Dữ liệu cá nhân như tên, địa chỉ và thông tin đơn hàng sẽ chỉ được sử dụng để cung cấp dịch vụ tốt hơn. '
            'Chúng tôi không chia sẻ thông tin của bạn với bên thứ ba nếu không có sự đồng ý rõ ràng từ bạn.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
