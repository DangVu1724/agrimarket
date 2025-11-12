import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../buyer_vm.dart';

class ProfileStats extends StatelessWidget {
  final BuyerVm buyerVm;

  const ProfileStats({super.key, required this.buyerVm});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (buyerVm.buyerData.value == null) {
        return _buildLoadingStatsCards();
      }

      final totalOrders = buyerVm.buyerData.value!.totalOrders ?? 0;
      final points = buyerVm.buyerData.value!.points ?? 0;
      final favouriteStores = buyerVm.buyerData.value!.favoriteStoreIds.length;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: StatCard(
                value: totalOrders.toString(),
                label: "Đơn hàng",
                icon: Iconsax.shopping_bag,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: points.toString(),
                label: "Điểm tích lũy",
                icon: Iconsax.gift,
                color: Colors.pink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: favouriteStores.toString(),
                label: "Yêu thích",
                icon: Iconsax.star,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingStatsCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(child: LoadingStatCard()),
          const SizedBox(width: 12),
          Expanded(child: LoadingStatCard()),
          const SizedBox(width: 12),
          Expanded(child: LoadingStatCard()),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingStatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        children: [
          CircleAvatar(backgroundColor: Colors.grey, radius: 20),
          SizedBox(height: 8),
          LinearProgressIndicator(),
          SizedBox(height: 4),
          LinearProgressIndicator(),
        ],
      ),
    );
  }
}