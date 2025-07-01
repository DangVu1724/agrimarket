import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/features/seller/other/viewmodel/create_store_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:latlong2/latlong.dart';

class StoreAddressScreen extends StatelessWidget {
  const StoreAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateStoreViewModel vm = Get.find<CreateStoreViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm địa chỉ',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Obx(() {
        final selected = vm.selectedLocation.value ?? const LatLng(21.0278, 105.8342); // Hà Nội
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
                        child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              top: 10,
              left: 15,
              right: 15,
              child: Column(
                children: [
                  TextField(
                    controller: vm.labelController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập nhãn địa chỉ (VD: Nhà, Văn phòng)...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: vm.addressController,
                    decoration: InputDecoration(
                      hintText: 'Nhập địa chỉ...',
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          vm.searchAddress(vm.addressController.text);
                        },
                        icon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () async {
                  final args = Get.arguments;
                  if (args != null && args['isEditing'] == true) {
    final StoreModel store = args['store'];
    final newStore = store.copyWith(
      storeLocation: vm.toStoreAddress(),
    );

    await vm.updateStoreLocation(newStore);
    Get.back(); 
    Get.snackbar('Thành công', 'Cập nhật địa chỉ cửa hàng thành công');
  } else {
                    vm.saveStore();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Lưu địa chỉ', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        );
      }),
    );
  }
}
