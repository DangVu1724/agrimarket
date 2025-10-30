import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:agrimarket/core/constants/env_config.dart';

class NotificationService {
  /// Lấy Firebase ID Token của user hiện tại
  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? await user.getIdToken(true) : null;
  }

  /// Đăng ký FCM token của client lên server
  Future<void> registerToken(String token) async {
    final idToken = await _getIdToken();
    if (idToken == null) {
      print('❌ User not logged in -> cannot register token');
      return;
    }

    final uri = Uri.parse('${EnvConfig.recoApiBaseUrl}/notification/register-token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };

    final body = jsonEncode({
      'token': token,
      'platform': Platform.operatingSystem,
    });

    final response = await http.post(uri, headers: headers, body: body);
    print('Register token response: ${response.statusCode} ${response.body}');
  }

  /// Buyer đặt hàng -> tạo đơn
  Future<String?> createOrder(Map<String, dynamic> orderData) async {
  try {
    final idToken = await _getIdToken();
    if (idToken == null) {
      print(' User not logged in -> cannot create order');
      return null;
    }

    final uri = Uri.parse('${EnvConfig.recoApiBaseUrl}/order');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };

    final body = jsonEncode(orderData);

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id']; // orderId từ server
    } else {
      print('Failed to create order: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Exception in createOrder: $e');
    return null;
  }
}


  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
  final idToken = await _getIdToken();
  if (idToken == null) {
    print('User not logged in -> cannot update order');
    return false;
  }

  final uri = Uri.parse('${EnvConfig.recoApiBaseUrl}/order/$orderId/status');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $idToken',
  };
  final body = jsonEncode({'newStatus': newStatus});

  final resp = await http.put(uri, headers: headers, body: body);
  print('Update order response: ${resp.statusCode} ${resp.body}');
  return resp.statusCode == 200;
}
}

