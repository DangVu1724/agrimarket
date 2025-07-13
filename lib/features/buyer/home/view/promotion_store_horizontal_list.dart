import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/store_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromotionStoreHorizontalList extends StatelessWidget {
  const PromotionStoreHorizontalList({super.key});

  @override
  Widget build(BuildContext context) {
    final storeVm = Get.find<StoreVm>();

    return Obx(() {
      if (storeVm.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final stores = storeVm.storesListPromotion.take(10).toList();
      if (stores.isEmpty) {
        return const Center(child: Text('Không có cửa hàng khuyến mãi'));
      }

      return Container(
        height: 150,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: stores.length,
          itemBuilder: (_, index) {
            final store = stores[index];

            return GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.store, arguments: store);
              },
              child: Container(
                width: 120,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                          store.storeImageUrl != null && store.storeImageUrl!.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  store.storeImageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 100,
                                ),
                              )
                              : const Icon(Icons.store, size: 40),
                    ),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (store.isPromotion)
                            Text(
                              'Khuyến mãi',
                              style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
