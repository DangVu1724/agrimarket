import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NetworkService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool hasConnection = true.obs;
  bool _dialogShown = false;

  @override
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
        onWillPop: () async => false,
        child: const AlertDialog(
          title: Text('Không có mạng'),
          content: Text('Vui lòng kiểm tra kết nối internet của bạn.'),
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      print('📥 Dialog bị đóng');
      _dialogShown = false;
    });
  }

  void _closeNoConnectionDialog() {
    if (_dialogShown) {
      Get.back();
      _dialogShown = false;
    }
  }
}
