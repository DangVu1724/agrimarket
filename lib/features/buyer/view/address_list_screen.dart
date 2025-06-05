import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/buyer/viewmodel/add_address_vm.dart';
import 'package:agrimarket/features/buyer/viewmodel/buyer_vm%20.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BuyerVm buyerVm = Get.find<BuyerVm>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Địa chỉ giao hàng', style: AppTextStyles.headline),
        centerTitle: true,
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: buyerVm.address.length,
          itemBuilder: (context, index) {
            final addr = buyerVm.address[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                title: Text(
                  addr.label,
                  style: AppTextStyles.headline.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                subtitle: Text(
                  addr.address,
                  style: AppTextStyles.body.copyWith(color: Colors.grey[600], fontSize: 16),
                ),
                leading: IconButton(
                  onPressed: () {
                    Get.defaultDialog(
                      contentPadding: EdgeInsets.all(20),
                      backgroundColor: AppColors.background,
                      title: 'Xác nhận',
                      titleStyle: AppTextStyles.headline.copyWith(
                        color: AppColors.primary,
                        fontSize: 28
                      ),
                      middleText: 'Bạn có chắc muốn xóa địa chỉ này không?',                     
                      textConfirm: 'Xóa',
                      textCancel: 'Hủy',
                      confirmTextColor: Colors.white,
                      cancelTextColor: AppColors.textPrimary,
                      buttonColor: AppColors.primary,
                      onConfirm: () {
                        Get.back(); 
                        Get.find<AddressViewModel>().deleteAddress(index);
                      },
                    );
                  },
                  icon: Icon(Icons.delete, size: 16, color: Colors.red),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, size: 16, color: AppColors.primary),
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.addAddress,
                      arguments: {
                        'address': addr,
                        'index': index,
                        'isEditing': true,
                      },
                    );
                  },
                ),
                onTap: () {
                  // Handle address selection
                  Get.snackbar('Địa chỉ đã chọn', addr.label);
                },
              ),
            );
          },
        );
      }),
      
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add_location_alt, color: Colors.white),
        label: Text(
          "Thêm địa chỉ",
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
        onPressed: () {
          Get.toNamed(
            AppRoutes.addAddress,
            arguments: {
              'onAddressAdded': () {
                Get.find<BuyerVm>().fetchBuyerData();
              },
            },
          );
        },
      ),
    );
  }
}
