import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Thông tin ứng dụng', style: AppTextStyles.headline),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.eco,
                        size: 100,
                        color: AppColors.primary,
                      ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'AgriMarket',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Phiên bản: 1.0.0',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                'AgriMarket là ứng dụng kết nối người nông dân với người tiêu dùng. '
                'Chúng tôi mang đến trải nghiệm mua nông sản trực tiếp, minh bạch và an toàn. '
                'Với AgriMarket, bạn có thể dễ dàng tìm kiếm, đặt mua các sản phẩm nông sản tươi sạch '
                'và hỗ trợ nông dân địa phương.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 20),
              // Tính năng nổi bật
              Text(
                'Tính năng nổi bật',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              const BulletPoint('Tìm kiếm nông sản theo khu vực.'),
              const BulletPoint('Đặt hàng trực tiếp từ nông dân.'),
              const BulletPoint('Theo dõi đơn hàng và lịch sử giao dịch.'),
              const BulletPoint('Lưu địa chỉ giao hàng với bản đồ tương tác.'),
              const SizedBox(height: 20),
              const Text(
                'Nhóm phát triển: AgriTeam',
                style: TextStyle(fontSize: 16),
              ),
              const Text('Email liên hệ: contact@agrimarket.vn'),
            ],
          ),
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
