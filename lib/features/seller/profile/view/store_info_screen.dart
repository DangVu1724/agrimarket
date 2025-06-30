import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/custom_text_form_field.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:agrimarket/features/seller/profile/viewmodel/store_info_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreInfoScreen extends StatelessWidget {
  const StoreInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StoreInfoVm storeInfoVm = Get.find<StoreInfoVm>();
    final SellerHomeVm vm = Get.find<SellerHomeVm>();

    if (vm.store.value != null) {
      storeInfoVm.loadExistingStore(vm.store.value!);
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Thông tin cửa hàng', style: AppTextStyles.headline),
        centerTitle: true,
      ),
      body: 
      // Obx(() {
      //   return 
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomTextFormField(
                label: 'Tên cửa hàng',
                hintText: 'Nhập tên',
                controller: storeInfoVm.storeNameController,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên cửa hàng' : null,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                label: 'Mô tả cửa hàng',
                hintText: 'Nhập mô tả',
                controller: storeInfoVm.storeDesController,
                keyboard: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập mô tả cửa hàng' : null,
              ),
              const SizedBox(height: 20,),

              Container(
                child: Row(
                  children: [
                    Column(
                      children: [
                        
                      ],
                    )
                  ],
                ),
              )


            ],
          ),
        )
      // }),
    );
  }
}
