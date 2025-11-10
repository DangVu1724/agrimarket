import 'package:flutter/material.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/app/theme/app_text_styles.dart';

class StoreInfoWidget extends StatelessWidget {
  final StoreModel store;

  const StoreInfoWidget({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tên cửa hàng
        Row(
          children: [
            Icon(Icons.store, color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                store.name,
                style: AppTextStyles.headline.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Địa chỉ
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 18),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                store.storeLocation.address,
                style: AppTextStyles.body.copyWith(fontSize: 15, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Trạng thái mở cửa
        Row(
          children: [
            Icon(Icons.access_time, color: Colors.blue, size: 18),
            const SizedBox(width: 4),
            Text(
              store.isOpened ? 'Mở cửa' : 'Đóng cửa',
              style: TextStyle(
                color: store.isOpened ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Mô tả
        Text('Mô tả cửa hàng:', style: AppTextStyles.headline.copyWith(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          store.description.isNotEmpty ? store.description : 'Chưa có mô tả.',
          style: AppTextStyles.body.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 16),

        // Danh mục
        Text('Danh mục:', style: AppTextStyles.headline.copyWith(fontSize: 16)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: store.categories
              .map((cat) => Chip(backgroundColor: AppColors.background, label: Text(cat)))
              .toList(),
        ),
      ],
    );
  }
}