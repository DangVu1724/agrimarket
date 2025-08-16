import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/core/widgets/promotion_badge.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreTile extends StatelessWidget {
  final StoreModel store;
  final String? distanceText;
  final int? estimatedTime;

  const StoreTile({Key? key, required this.store, this.distanceText, this.estimatedTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeInfo = (distanceText != null) ? "🛵 $distanceText • ⏱ $estimatedTime phút" : "Không xác định vị trí";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.15), spreadRadius: 2, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.store, arguments: store),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PromotionBadgeOverlay(
              isPromotion: store.isPromotion,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    store.storeImageUrl?.isNotEmpty == true
                        ? Image.network(
                          store.storeImageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.store, size: 50),
                        )
                        : const Icon(Icons.store, size: 50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.name, style: AppTextStyles.headline.copyWith(fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    store.storeLocation.address,
                    style: AppTextStyles.body.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(timeInfo, style: AppTextStyles.body.copyWith(fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (store.rating != null) ...[
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              store.rating.toString(),
                              style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                      ],
                      store.isPromotion
                          ? PromotionBadgeWithText(isPromotion: store.isPromotion, text: 'Khuyến mãi')
                          : const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
