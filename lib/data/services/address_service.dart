import 'dart:convert';
import 'dart:math';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class AddressService {
  static Future<String> getAddressFromLatLng(LatLng latLng) async {
    final placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      return "${p.street ?? ''}, ${p.subAdministrativeArea ?? ''}, ${p.administrativeArea ?? ''}, ${p.country ?? ''}"
          .trim();
    }
    return "";
  }

  static Future<LatLng?> getLatLngFromAddress(String address) async {
    final locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      final loc = locations.first;
      return LatLng(loc.latitude, loc.longitude);
    }
    return null;
  }

  /// Trả về khoảng cách (km) giữa 2 điểm theo tọa độ
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Bán kính Trái Đất (km)

    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) + cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = R * c;

    return distance;
  }

  double _deg2rad(double deg) => deg * pi / 180;

  Future<int> getEstimatedTravelTime(double originLat, double originLng, double destLat, double destLng) async {
    final apiKey = '5b3ce3597851110001cf6248abd1829a918c4c28add13a6bcaa284b9';

    final url = Uri.parse('https://api.openrouteservice.org/v2/matrix/driving-car');

    final body = jsonEncode({
      "locations": [
        [originLng, originLat], // Lưu ý: OpenRouteService dùng format [lon, lat]
        [destLng, destLat],
      ],
      "metrics": ["duration"],
      "units": "km",
    });

    final response = await http.post(
      url,
      headers: {'Authorization': apiKey, 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // data['durations'] là ma trận thời gian (giây)
      // durations[0][1] là thời gian từ điểm 0 đến điểm 1
      final durations = data['durations'] as List<dynamic>?;
      if (durations != null && durations.length > 0) {
        final durationSec = durations[0][1];
        if (durationSec != null) {
          // Chuyển sang phút và làm tròn
          final durationMin = (durationSec / 60).round();
          return durationMin;
        }
      }
      return 0;
    } else {
      return 0;
    }
  }
}
