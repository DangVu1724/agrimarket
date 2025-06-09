import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Trợ giúp',style: AppTextStyles.headline,),
          centerTitle: true,
          backgroundColor: Colors.white,
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              'Câu hỏi thường gặp:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('1. Làm sao để thêm địa chỉ mới?\n→ Vào mục "Địa chỉ" và nhấn nút Thêm.'),
            SizedBox(height: 10),
            Text('2. Làm sao để đặt hàng?\n→ Chọn sản phẩm, thêm vào giỏ và tiến hành thanh toán.'),
            SizedBox(height: 10),
            Text('3. Tôi có thể liên hệ hỗ trợ ở đâu?\n→ Liên hệ email: support@agrimarket.vn'),
          ],
        ),
      ),
    );
  }
}
