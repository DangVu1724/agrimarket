import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class AddressViewModel extends GetxController {
  final TextEditingController addressController = TextEditingController();
  final Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  final isLoading = false.obs;
  final mapController = MapController();

  void selectLocation(LatLng latLng) async {
    selectedLocation.value = latLng;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        addressController.text =
            "${placemark.street}, ${placemark.locality}, ${placemark.country}";
      }
      mapController.move(latLng, 15.0); // Di chuyển bản đồ đến vị trí đã chọn
    } catch (e) {
      print("Lỗi khi lấy địa chỉ từ tọa độ: $e");
    }
  }

  void searchAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);
        selectedLocation.value = latLng;
        mapController.move(latLng, 15);
      }
    } catch (e) {
      print("Lỗi khi tìm tọa độ từ địa chỉ: $e");
    }
  }
}
