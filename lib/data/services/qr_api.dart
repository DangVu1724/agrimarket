import 'dart:convert';
import 'package:http/http.dart' as http;

class VietQRService {
  final String clientId;
  final String apiKey;

  VietQRService({required this.clientId, required this.apiKey});

  /// Tạo QR VietQR
  Future<String?> generateVietQR({
    required String accountNo,
    required String accountName,
    required int acqId,
    required int amount,
    String addInfo = '',
    String format = 'text',
    String template = 'compact',
  }) async {
    final url = Uri.parse('https://api.vietqr.io/v2/generate');

    final headers = {
      'Content-Type': 'application/json',
      'x-client-id': clientId,
      'x-api-key': apiKey,
    };

    final body = jsonEncode({
      'accountNo': accountNo,
      'accountName': accountName,
      'acqId': acqId.toString(),
      'amount': amount.toString(),
      'addInfo': addInfo,
      'format': format,
      'template': template,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['code'] == '00') {
        // VietQR trả về text để dùng tạo QR
        return data['data']['qrCode'] ?? null;
      } else {
        print('Lỗi tạo VietQR: ${data['desc']}');
        return null;
      }
    } catch (e) {
      print('Lỗi gọi API VietQR: $e');
      return null;
    }
  }
}
