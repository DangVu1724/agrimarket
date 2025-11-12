import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/buyer/other/viewmodel/add_address_vm.dart';
import 'package:agrimarket/features/buyer/buyer_vm.dart';
import 'package:agrimarket/features/buyer/profile/viewmodel/address_list_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressListScreen extends StatelessWidget {
  AddressListScreen({super.key});

  final BuyerVm buyerVm = Get.find<BuyerVm>();
  final AddressViewModel addAddressVm = Get.find<AddressViewModel>();
  final AddressListVm addressVm = Get.find<AddressListVm>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Địa chỉ giao hàng', style: AppTextStyles.headline),
        centerTitle: true,
      ),
      body: Obx(() {
        final defaultAddresses =
            buyerVm.address.where((addr) => addr.isDefault == true).toList();
        final otherAddresses =
            buyerVm.address.where((addr) => addr.isDefault != true).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            if (defaultAddresses.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  'Địa chỉ mặc định',
                  style: AppTextStyles.headline.copyWith(fontSize: 22),
                ),
              ),
              ...defaultAddresses
                  .map(
                    (addr) => _buildAddressTile(
                      addr,
                      buyerVm.address.indexOf(addr),
                      buyerVm,
                    ),
                  )
                  .toList(),
            ],
            if (otherAddresses.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  'Địa chỉ khác',
                  style: AppTextStyles.headline.copyWith(fontSize: 22),
                ),
              ),
              ...otherAddresses
                  .map(
                    (addr) => _buildAddressTile(
                      addr,
                      buyerVm.address.indexOf(addr),
                      buyerVm,
                    ),
                  )
                  .toList(),
            ],
            if (buyerVm.address.isEmpty)
              Center(
                child: Text('Chưa có địa chỉ nào.', style: AppTextStyles.body),
              ),
          ],
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
                buyerVm.fetchBuyerData();
              },
            },
          );
        },
      ),
    );
  }

  Widget _buildAddressTile(addr, int index, BuyerVm buyerVm) {
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
        title: Row(
          children: [
            Text(
              addr.label,
              style: AppTextStyles.headline.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (addr.isDefault == true) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Mặc định',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          addr.address,
          style: AppTextStyles.body.copyWith(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.defaultDialog(
              contentPadding: EdgeInsets.all(20),
              backgroundColor: AppColors.background,
              title: 'Xác nhận',
              titleStyle: AppTextStyles.headline.copyWith(
                color: AppColors.primary,
                fontSize: 28,
              ),
              middleText: 'Bạn có chắc muốn xóa địa chỉ này không?',
              textConfirm: 'Xóa',
              textCancel: 'Hủy',
              confirmTextColor: Colors.white,
              cancelTextColor: AppColors.textPrimary,
              buttonColor: AppColors.primary,
              onConfirm: () {
                Get.back();
                addressVm.deleteAddress(index);
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
              arguments: {'address': addr, 'index': index, 'isEditing': true},
            );
          },
        ),
        onTap: () {
          Get.defaultDialog(
            backgroundColor: AppColors.background,
            title: 'Đặt địa chỉ mặc định',
            titleStyle: AppTextStyles.headline.copyWith(
              color: AppColors.primary,
              fontSize: 28,
            ),
            middleText:
                'Bạn có muốn đặt địa chỉ này làm địa chỉ mặc định không?',
            textConfirm: 'Đồng ý',
            textCancel: 'Hủy',
            confirmTextColor: Colors.white,
            cancelTextColor: AppColors.textPrimary,
            buttonColor: AppColors.primary,
            onConfirm: () {
              Get.back();
              addAddressVm.setDefaultAddress(index);
            },
          );
        },
      ),
    );
  }
}
