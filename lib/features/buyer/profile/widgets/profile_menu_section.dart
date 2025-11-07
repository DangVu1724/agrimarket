import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileMenuSection extends StatelessWidget {
  final String title;
  final List<MenuItem> items;

  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        ...items.map((item) => ProfileMenuCard(item: item)),
      ],
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final Color color;
  final String? route;
  final VoidCallback? onTap;
  final bool isLogout;

  MenuItem({
    required this.icon,
    required this.title,
    required this.color,
    this.route,
    this.onTap,
    this.isLogout = false,
  });
}

class ProfileMenuCard extends StatelessWidget {
  final MenuItem item;

  const ProfileMenuCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _handleTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildIcon(),
                const SizedBox(width: 12),
                _buildTitle(),
                const Spacer(),
                _buildTrailingIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(item.icon, color: item.color, size: 20),
    );
  }

  Widget _buildTitle() {
    return Expanded(
      child: Text(
        item.title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: item.isLogout ? Colors.red : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTrailingIcon() {
    return Icon(
      Icons.arrow_forward_ios_rounded,
      color: item.isLogout ? Colors.red : Colors.grey.shade400,
      size: 16,
    );
  }

  void _handleTap() {
    if (item.onTap != null) {
      item.onTap!();
    } else if (item.route != null) {
      Get.toNamed(item.route!);
    }
  }
}