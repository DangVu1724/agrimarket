import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/data/models/buyer.dart';
import 'package:agrimarket/data/services/address_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm.dart';
import 'package:agrimarket/features/buyer/home/viewmodel/recommendation_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RecommendedStoreHorizontalList extends StatelessWidget {
  const RecommendedStoreHorizontalList({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<RecommendationVm>();
    final buyerVm = Get.find<BuyerVm>();
    final addressService = AddressService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.thumb_up_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Gợi ý cho bạn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to all recommended stores
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Stores List
        Obx(() {
          if (vm.isLoading.value) {
            return SizedBox(
              height: 170,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue.shade600,
                ),
              ),
            );
          }
          
          final stores = vm.recommendedStores;
          final buyer = buyerVm.buyerData.value;

          if (stores.isEmpty || buyer == null) {
            return const SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Không có cửa hàng gợi ý',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stores.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (_, index) {
                final store = stores[index];
                final storeLatLng = store.getDefaultLatLng();
                final buyerLatLng = buyer.getDefaultLatLng();

                if (storeLatLng == null || buyerLatLng == null) {
                  return _buildStoreCard(store, null, null, index);
                }

                // Tính khoảng cách
                final distance = addressService.calculateDistance(
                  buyerLatLng[0],
                  buyerLatLng[1],
                  storeLatLng[0],
                  storeLatLng[1],
                );
                final formattedDistance = NumberFormat('#,##0.0', 'vi_VN').format(distance);

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

                    return _buildStoreCard(store, '$formattedDistance km', totalTime, index);
                  },
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStoreCard(store, String? distanceText, int? estimatedTime, int index) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.store, arguments: store);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Image with Badge
                Stack(
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        color: Colors.grey.shade100,
                      ),
                      child: store.storeImageUrl != null && store.storeImageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.network(
                                store.storeImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 120,
                                errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                              ),
                            )
                          : _buildPlaceholderIcon(),
                    ),
                    
                    // Recommendation Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                  ],
                ),
                
                // Store Info
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Name
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Rating
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, size: 12, color: Colors.yellow),
                                const SizedBox(width: 2),
                                Text(
                                  (store.rating ?? 4.0).toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Distance and Time
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 12, color: Colors.redAccent),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              distanceText ?? 'Gần bạn',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      if (estimatedTime != null && estimatedTime > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: Colors.blueAccent),
                            const SizedBox(width: 2),
                            Text(
                              '$estimatedTime phút',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.store_outlined,
        size: 40,
        color: Colors.grey.shade400,
      ),
    );
  }
}