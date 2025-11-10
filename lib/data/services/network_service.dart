import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NetworkService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool hasConnection = true.obs;
  bool _dialogShown = false;

  @override
  void onInit() {
    super.onInit();

    _checkInitialConnection(); // kiểm tra lần đầu

    _connectivity.onConnectivityChanged.listen((result) {
      print('🔄 Kết nối thay đổi: $result');

      // Trường hợp: đôi khi `result` là List<ConnectivityResult>
      // Bạn đang log: [ConnectivityResult.none] (có dấu ngoặc vuông)
      final singleResult = result is List ? result.first : result;

      final connected = singleResult != ConnectivityResult.none;

      print(connected ? '✅ Có mạng - gọi _closeNoConnectionDialog()' : '❌ Mất mạng - gọi _showNoConnectionDialog()');

      hasConnection.value = connected;

      if (!connected) {
        _showNoConnectionDialog();
      } else {
        _closeNoConnectionDialog();
      }
    });
  }

  void _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    bool connected = result != ConnectivityResult.none;
    hasConnection.value = connected;

    if (!connected) {
      _showNoConnectionDialog();
    }
  }

  void _showNoConnectionDialog() {
    if (_dialogShown) {
      print('⚠️ Dialog đã hiện rồi');
      return;
    }

    _dialogShown = true;
    print('📣 Hiển thị dialog mất mạng');

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // không cho đóng bằng nút back
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.wifi_off, size: 60, color: Colors.redAccent),
                SizedBox(height: 16),
                Text(
                  'Không có kết nối mạng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Vui lòng kiểm tra Wi-Fi hoặc dữ liệu di động của bạn.',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false, // không cho tắt bằng cách bấm ra ngoài
    ).then((_) => _dialogShown = false);
  }


  void _closeNoConnectionDialog() {
    if (_dialogShown) {
      Get.back();
      _dialogShown = false;
    }
  }
}
