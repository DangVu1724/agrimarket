import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/data/models/buyer.dart';
import 'package:agrimarket/data/services/address_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/recommendation_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NearbyStores extends StatelessWidget {
  const NearbyStores({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<RecommendationVm>();
    final buyerVm = Get.find<BuyerVm>();
    final addressService = AddressService();

    return Obx(() {
      if (vm.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final stores = vm.nearbyStores;
      final buyer = buyerVm.buyerData.value;

      if (stores.isEmpty || buyer == null) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 170,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: stores.length,
          itemBuilder: (_, index) {
            final store = stores[index];
            final storeLatLng = store.getDefaultLatLng();
            final buyerLatLng = buyer.getDefaultLatLng();

            if (storeLatLng == null || buyerLatLng == null) {
              return _buildStoreCard(store, null, null);
            }

            // Tính khoảng cách
            final distance = addressService.calculateDistance(
              buyerLatLng[0],
              buyerLatLng[1],
              storeLatLng[0],
              storeLatLng[1],
            );
            final formattedDistance = NumberFormat('#,##0.00', 'vi_VN').format(distance);

            return FutureBuilder<int>(
              future: addressService.getEstimatedTravelTime(
                storeLatLng[0],
                storeLatLng[1],
                buyerLatLng[0],
                buyerLatLng[1],
              ),
              builder: (context, snapshot) {
                final estimatedTime = snapshot.hasData ? snapshot.data! : 0;
                final int prepareTime = 15;
                final int totalTime = prepareTime + estimatedTime;

                return _buildStoreCard(store, '$formattedDistance km', totalTime);
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildStoreCard(store, String? distanceText, int? estimatedTime) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.store, arguments: store);
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
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
              child: Text(
                store.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 2),
                    if (store.rating != null && store.rating! > 0) ...[
                      Text('${store.rating}', style: TextStyle(fontSize: 12)),
                    ] else ... [
                      Text('4.0', style: TextStyle(fontSize: 12)),
                    ],
                  ],
                ),

                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.red),
                    const SizedBox(width: 2),
                    Text(
                      distanceText ?? store.storeLocation.address,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
