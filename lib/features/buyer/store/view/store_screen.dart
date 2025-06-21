import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/store_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreScreen extends StatelessWidget {
  final String storeId;

  const StoreScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final StoreVm vm = Get.find<StoreVm>();

    // Fetch đúng 1 lần
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.storeData.value == null ||
          vm.storeData.value!.storeId != storeId) {
        vm.fetchStoreByID(storeId);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar và body dùng Obx để reactive
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: Obx(() {
          final store = vm.storeData.value;

          return AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              store?.name ?? 'Store',
              style: AppTextStyles.headline.copyWith(color: Colors.white),
            ),
            flexibleSpace: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  (store?.storeImageUrl?.isNotEmpty ?? false)
                      ? store!.storeImageUrl!
                      : 'https://via.placeholder.com/600x200?text=No+Image',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Text('Không thể tải ảnh'),
                    );
                  },
                ),
                Container(
                  color: Colors.black.withOpacity(0.3), // Lớp mờ overlay
                ),
              ],
            ),
          );
        }),
      ),
      body: Center(
        child: Obx(() {
          if (vm.isLoading.value) {
            return const CircularProgressIndicator();
          }

          final store = vm.storeData.value;

          if (store == null) {
            return const Text('Không tìm thấy cửa hàng');
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to Store: ${store.name}',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              const Text(
                'Explore our products and offers.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          );
        }),
      ),
    );
  }
}
