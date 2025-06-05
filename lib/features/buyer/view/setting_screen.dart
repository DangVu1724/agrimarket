import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> sectionItems = [
      {'icon': Icons.password, 'title': 'Đổi mật khẩu'},
      {'icon': Icons.notifications, 'title': 'Thông báo'},
      {'icon': Icons.privacy_tip, 'title': 'Quyền riêng tư'},
      {'icon': Icons.security, 'title': 'Bảo mật'},
      {'icon': Icons.info, 'title': 'Thông tin ứng dụng'},
      {'icon': Icons.help, 'title': 'Trợ giúp'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...sectionItems.map((item) => 
              _buildSectionButton(item['icon'], item['title'])
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionButton(IconData icon, String title) {
    return TextButton(
      onPressed: () async {
        try {
          switch (title) {
            case 'Đổi mật khẩu':
              Get.toNamed(AppRoutes.resetPassword);
              break;
  
            default:
              Get.snackbar('Tính năng', '$title chưa được hỗ trợ');
          }
        } catch (e, st) {
          debugPrint('Error on button "$title": $e\n$st');
        }
      },

      style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black),
                SizedBox(width: 16),
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

