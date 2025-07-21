import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.primary,
          pinned: true,
          expandedHeight: 150,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite, color: Colors.white),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chat, color: Colors.white),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(color: Colors.grey[300]),
            title: Container(width: 150, height: 24, color: Colors.grey[300]),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 200, height: 14, color: Colors.grey[300]),
                const SizedBox(height: 4),
                Container(width: 100, height: 14, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
        MultiSliver(
          children: [
            SliverStickyHeader(
              header: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 100,
                  height: 20,
                  color: Colors.grey[300],
                ),
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 80,
                        height: 70,
                        color: Colors.grey[300],
                      ),
                      title: Container(
                        width: 100,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      subtitle: Container(
                        width: 60,
                        height: 14,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                  childCount: 3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}