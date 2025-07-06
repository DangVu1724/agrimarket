import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/custom_text_form_field.dart';
import 'package:agrimarket/data/services/seller_store_service.dart';
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
    final SellerStoreService sellerStoreService = SellerStoreService();
    final formKey = GlobalKey<FormState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.store.value != null && storeInfoVm.currentStore.value == null) {
        sellerStoreService.getCurrentSellerStore().then((store) {
          if (store != null) {
            storeInfoVm.loadExistingStore(store);
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Thông tin cửa hàng', style: AppTextStyles.headline),
        centerTitle: true,
      ),
      body: Obx(() {
        final currentStore = storeInfoVm.currentStore.value;
        if (currentStore == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            final refreshed = await sellerStoreService.getCurrentSellerStore();
            if (refreshed != null) {
              storeInfoVm.updateCurrentStore(refreshed);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      keyboard: TextInputType.text,
                      validator: (value) => value!.isEmpty ? 'Vui lòng nhập mô tả cửa hàng' : null,
                    ),
                    const SizedBox(height: 20),
                    const Divider(),

                    Text("Địa chỉ cửa hàng", style: AppTextStyles.headline),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        title: Text(currentStore.storeLocation.label, style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(currentStore.storeLocation.address),
                        trailing: IconButton(
                          onPressed: () {
                            Get.toNamed(
                              AppRoutes.createStoreAddress,
                              arguments: {'isEditing': true, 'store': currentStore},
                            );
                          },
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green.shade600,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            storeInfoVm.saveStoreInfo();
                          }
                        },
                        child: const Text("Lưu thông tin", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
