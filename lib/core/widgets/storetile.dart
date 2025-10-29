import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreTile extends StatelessWidget {
  final StoreModel store;
  final String? distanceText;
  final int? estimatedTime;

  const StoreTile({
    Key? key, 
    required this.store, 
    this.distanceText, 
    this.estimatedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeInfo = (distanceText != null) 
        ? "🛵 $distanceText • ⏱ $estimatedTime phút" 
        : "Không xác định vị trí";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.store, arguments: store),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Image
                _buildStoreImage(),
                const SizedBox(width: 16),
                
                // Store Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Name and Categories
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              store.name,
                              style: AppTextStyles.headline.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildCategories(),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Distance and Time
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              timeInfo,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Rating and Tags
                      Row(
                        children: [
                          // Rating
                          if (store.rating != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    store.rating!.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '(${store.totalReviews ?? 0})',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          
                          // Tags
                          if (store.tags != null && store.tags!.isNotEmpty) ...[
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: store.tags!.take(2).map((tag) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: _buildTagChip(tag),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildStoreImage() {
    return Stack(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade100,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: store.storeImageUrl?.isNotEmpty == true
                ? Image.network(
                    store.storeImageUrl!,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
                  )
                : _buildPlaceholderIcon(),
          ),
        ),
        
        // Online Status Indicator
        if (store.isOpened == true)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategories() {
    if (store.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        store.categories.first,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    final color = _tagColor(tag);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _tagIcon(tag),
            size: 12,
            color: color.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            _tagLabel(tag),
            style: TextStyle(
              color: color.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
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

  /// 🎨 Màu chính cho từng tag
  MaterialColor _tagColor(String tag) {
    switch (tag) {
      case 'new_store':
        return Colors.green;
      case 'experienced':
        return Colors.blue;
      case 'bestseller':
        return Colors.orange;
      case 'top_seller':
        return Colors.red;
      case 'trusted':
        return Colors.teal;
      case 'elite_store':
        return Colors.purple;
      case 'inactive_store':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  /// 🏷️ Nhãn hiển thị
  String _tagLabel(String tag) {
    switch (tag) {
      case 'new_store':
        return 'Mới';
      case 'experienced':
        return 'Đỉnh';
      case 'bestseller':
        return 'Bán chạy';
      case 'top_seller':
        return 'Top Seller';
      case 'trusted':
        return 'Uy tín';
      case 'elite_store':
        return 'Xuất sắc';
      case 'inactive_store':
        return 'Ít hoạt động';
      default:
        return tag;
    }
  }

  /// 🔸 Icon cho từng tag
  IconData _tagIcon(String tag) {
    switch (tag) {
      case 'new_store':
        return Icons.fiber_new;
      case 'experienced':
        return Icons.workspace_premium;
      case 'bestseller':
        return Icons.trending_up;
      case 'top_seller':
        return Icons.emoji_events;
      case 'trusted':
        return Icons.verified;
      case 'elite_store':
        return Icons.diamond;
      case 'inactive_store':
        return Icons.pause_circle;
      default:
        return Icons.local_offer;
    }
  }
}