import 'package:agrimarket/core/constants/env_config.dart';
import 'package:http/http.dart' as http;

class ServerStatusService {
  Future<bool> isServerReady() async {
    try {
      final response = await http.get(
        Uri.parse("${EnvConfig.recoApiBaseUrl}/health"),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> waitForServer({int maxRetries = 10, int delaySeconds = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      if (await isServerReady()) return true;
      if (i < maxRetries - 1) {
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }
    return false;
  }
}