import 'dart:math';

import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class AddressService {
  static Future<String> getAddressFromLatLng(LatLng latLng) async {
    final placemarks = await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );
    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      return "${p.street ?? ''}, ${p.subAdministrativeArea ?? ''}, ${p.administrativeArea ?? ''}, ${p.country ?? ''}".trim();
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

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final distance = R * c;

  return distance;
}

double _deg2rad(double deg) => deg * pi / 180;





  
}
