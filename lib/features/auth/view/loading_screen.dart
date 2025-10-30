// lib/features/auth/view/server_loading_screen.dart
import 'package:agrimarket/data/services/status_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrimarket/app/routes/app_routes.dart';

class ServerLoadingScreen extends StatefulWidget {
  const ServerLoadingScreen({super.key});

  @override
  State<ServerLoadingScreen> createState() => _ServerLoadingScreenState();
}

class _ServerLoadingScreenState extends State<ServerLoadingScreen> {
  final ServerStatusService _serverService = ServerStatusService();
  int _dotsCount = 0;

  @override
  void initState() {
    super.initState();
    _startDotsAnimation();
    _waitForServer();
  }

  void _startDotsAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _dotsCount = (_dotsCount + 1) % 4;
        });
        _startDotsAnimation();
      }
    });
  }

  Future<void> _waitForServer() async {
    final bool isReady = await _serverService.waitForServer();
    
    if (isReady) {
      Get.offAllNamed(AppRoutes.buyerHome);
    } else {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Lỗi kết nối'),
          ],
        ),
        content: const Text(
          'Không thể kết nối đến server. Vui lòng thử lại sau.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('THOÁT'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _waitForServer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('THỬ LẠI'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E8), Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.agriculture_outlined,
                size: 60,
                color: Colors.green.shade600,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Loading text with animated dots
            Text(
              'Đang khởi động server${'.' * _dotsCount}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Loading indicator
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                backgroundColor: Colors.green.shade100,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Additional info
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Quá trình này có thể mất vài phút\nkhi server đang khởi động',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Progress steps (optional)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ProgressStep(number: 1, label: 'Kiểm tra'),
                  _ProgressStep(number: 2, label: 'Kết nối'),
                  _ProgressStep(number: 3, label: 'Sẵn sàng'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final int number;
  final String label;

  const _ProgressStep({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}