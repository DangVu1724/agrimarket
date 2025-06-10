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
}
