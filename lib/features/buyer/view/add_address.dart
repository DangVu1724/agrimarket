import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:agrimarket/features/buyer/viewmodel/add_address_vm.dart';

class AddressScreen extends StatelessWidget {
  final AddressViewModel vm = Get.put(AddressViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm địa chỉ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Obx(() {
        final selected =
            vm.selectedLocation.value ?? LatLng(21.0278, 105.8342); // Hà Nội
        return Stack(
          children: [
            FlutterMap(
              mapController: vm.mapController,
              options: MapOptions(
                initialCenter: selected,
                initialZoom: 15,
                onTap: (tapPosition, point) {
                  vm.selectLocation(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.agrimarket',
                ),
                if (vm.selectedLocation.value != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: vm.selectedLocation.value!,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_pin,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              top: 10,
              left: 15,
              right: 15,
              child: TextField(
                controller: vm.addressController,
                // onChanged: (value) {
                //   Future.delayed(Duration(milliseconds: 600), () {
                //     vm.searchAddress(value);
                //   }
                //   );
                // },
                decoration: InputDecoration(
                  hintText: 'Nhập địa chỉ...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(onPressed: () {
                    vm.searchAddress(vm.addressController.text);
                  }, icon: Icon(Icons.search)),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () async {
                  final location = vm.selectedLocation.value;
                  final address = vm.addressController.text;

                  if (location != null && address.isNotEmpty) {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .update({
                            'details': {
                              'address': address,
                              'lat': location.latitude,
                              'lng': location.longitude,
                            },
                          });
                      Get.offAllNamed(AppRoutes.buyerHome);
                    } else {
                      Get.snackbar('Lỗi', 'Không tìm thấy người dùng');
                    }
                  } else {
                    Get.snackbar(
                      'Thiếu thông tin',
                      'Vui lòng chọn vị trí hoặc nhập địa chỉ',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Lưu địa chỉ',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
