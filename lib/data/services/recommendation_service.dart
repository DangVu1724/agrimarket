import 'dart:convert';
import 'package:agrimarket/core/constants/env_config.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class RecommendationService {
  /// Lấy Firebase ID Token của user hiện tại
  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken(true);
    }
    return null;
  }

  Future<List<String>> fetchRecommendedStoreIds({double? lat, double? lng}) async {
    if (EnvConfig.recoApiBaseUrl.isEmpty) {
      print('RECO API Base URL is empty');
      return [];
    }

    final idToken = await _getIdToken();
    if (idToken == null) {
      print('User not logged in or failed to get ID Token');
      return [];
    }

    final uri = Uri.parse(
      '${EnvConfig.recoApiBaseUrl}/recommendations/stores',
    ).replace(queryParameters: {if (lat != null) 'lat': lat.toString(), if (lng != null) 'lng': lng.toString()});

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken', // gửi ID Token
    };

    print('--- Recommendation Request ---');
    print('URI: $uri');
    print('Headers: $headers');

    final response = await http.get(uri, headers: headers);

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        if (data['storeIds'] is List) {
          return List<String>.from(data['storeIds']);
        }
        if (data['stores'] is List) {
          return List<Map<String, dynamic>>.from(
            data['stores'],
          ).map((s) => (s['id'] ?? s['storeId'])?.toString()).whereType<String>().toList();
        }
      } else if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } else {
      print('Error fetching recommendations: ${response.statusCode} ${response.reasonPhrase}');
    }

    return [];
  }

  Future<List<String>> fetchNearbyStoreIds({required double lat, required double lng}) async {
    final idToken = await _getIdToken();
    if (idToken == null) {
      print('❌ User not logged in or failed to get ID Token');
      return [];
    }

    final uri = Uri.parse(
      '${EnvConfig.recoApiBaseUrl}/nearby/stores',
    ).replace(queryParameters: {'lat': lat.toString(), 'lng': lng.toString()});

    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $idToken'};

    print('--- Nearby Stores Request ---');
    print('URI: $uri');
    print('Headers: $headers');

    final response = await http.get(uri, headers: headers);

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data['storeIds'] is List) {
          print('✅ Fetched storeIds: ${data['storeIds']}');
          return List<String>.from(data['storeIds']);
        } else {
          print('⚠️ storeIds not found in response');
        }
      } catch (e) {
        print('❌ JSON decode error: $e');
      }
    } else {
      print('❌ Error fetching nearby stores: ${response.statusCode} ${response.reasonPhrase}');
    }

    return [];
  }
}
