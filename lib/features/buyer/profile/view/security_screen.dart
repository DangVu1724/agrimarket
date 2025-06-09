import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Bảo mật',style: AppTextStyles.headline),
          centerTitle: true,
          backgroundColor: Colors.white,
          
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'Chúng tôi áp dụng các biện pháp bảo mật như mã hóa dữ liệu và xác thực người dùng để đảm bảo thông tin cá nhân của bạn được an toàn. '
            'Thông tin thanh toán được bảo vệ qua cổng thanh toán bảo mật chuẩn quốc tế.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
