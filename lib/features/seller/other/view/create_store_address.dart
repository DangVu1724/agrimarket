import 'package:agrimarket/core/widgets/address_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/features/seller/other/viewmodel/create_store_vm.dart';

class StoreAddressScreen extends StatelessWidget {
  final CreateStoreViewModel vm = Get.find<CreateStoreViewModel>();

  StoreAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tạo cửa hàng - Bước 2',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => vm.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: vm.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin địa chỉ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomDropdownField<String>(
                        labelText: 'Tỉnh/Thành phố',
                        value: vm.selectedProvinceCode.value,
                        items: vm.provinces,
                        isLoading: vm.isLoadingProvinces.value ,
                        onChanged: (value) {
                          if (value != null) {
                            final selectedProvince = vm.provinces.firstWhere(
                              (p) => p['code'].toString() == value,
                              orElse: () => {'name': '', 'code': ''},
                            );
                            if (selectedProvince['name'] != '') {
                              vm.provinceController.text = selectedProvince['name'] as String;
                              vm.selectedProvinceCode.value = value;
                              vm.districtController.clear();
                              vm.wardController.clear();
                              print('Selected province: ${vm.provinceController.text}, code: $value');
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomDropdownField<String>(
                        labelText: 'Quận/Huyện',
                        value: vm.selectedDistrictCode.value,
                        items: vm.districts,
                        isLoading: vm.isLoadingDistricts.value,
                        isEnabled: vm.provinces.isNotEmpty,
                        hintText: vm.provinces.isEmpty ? 'Vui lòng chọn tỉnh/thành phố trước' : null,
                        onChanged: (value) {
                          if (value != null) {
                            final selectedDistrict = vm.districts.firstWhere(
                              (d) => d['code'].toString() == value,
                              orElse: () => {'name': '', 'code': ''},
                            );
                            if (selectedDistrict['name'] != '') {
                              vm.districtController.text = selectedDistrict['name'] as String;
                              vm.selectedDistrictCode.value = value;
                              vm.onDistrictChanged();
                              print('Selected district: ${vm.districtController.text}, code: $value');
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomDropdownField<String>(
                        labelText: 'Phường/Xã',
                        value: vm.districts.isNotEmpty ? vm.selectedWardCode.value : null,
                        items: vm.wards,
                        isLoading: vm.isLoadingWards.value,
                        isEnabled: vm.districts.isNotEmpty,
                        hintText: vm.districts.isEmpty ? 'Vui lòng chọn quận/huyện trước' : null,
                        onChanged: (value) {
                          if (value != null) {
                            final selectedWard = vm.wards.firstWhere(
                              (w) => w['code'].toString() == value,
                              orElse: () => {'name': '', 'code': ''},
                            );
                            if (selectedWard['name'] != '') {
                              vm.wardController.text = selectedWard['name'] as String;
                              vm.selectedWardCode.value = value;
                              vm.onWardChanged();
                              print('Selected ward: ${vm.wardController.text}, code: $value');
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: vm.streetController,
                        decoration: const InputDecoration(
                          labelText: 'Tên đường',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Vui lòng nhập tên đường' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: vm.houseNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Số nhà',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Vui lòng nhập số nhà' : null,
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: vm.isLoading.value
                            ? null
                            : () async {
                                if (vm.formKey.currentState!.validate()) {
                                  await vm.saveStore();
                                } else {
                                  Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin địa chỉ');
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: vm.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Hoàn tất',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}