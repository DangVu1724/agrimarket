import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../buyer_vm.dart';

class RankCard extends StatelessWidget {
  final BuyerVm buyerVm;

  const RankCard({super.key, required this.buyerVm});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (buyerVm.buyerData.value == null) {
        return _buildLoadingRankCard();
      }

      final rank = buyerVm.buyerData.value!.rank;
      final points = buyerVm.buyerData.value!.points ?? 0;
      final totalOrders = buyerVm.buyerData.value!.totalOrders ?? 0;

      final nextRank = _getNextRank(rank, points, totalOrders);
      final progress = _calculateProgress(rank, points, totalOrders);
      final remainingAmount = _getRemainingAmount(rank, points, totalOrders);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRankHeader(rank, remainingAmount, nextRank),
            const SizedBox(height: 12),
            _buildProgressBar(rank, nextRank, progress),
            const SizedBox(height: 8),
            _buildRankLabels(rank, nextRank),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingRankCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.grey, radius: 10),
              SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankHeader(String rank, int remainingAmount, String nextRank) {
    return Row(
      children: [
        Icon(Icons.workspace_premium_rounded,
            color: _getRankColor(rank), size: 20),
        const SizedBox(width: 8),
        Text(
          "Hạng ${_getRankDisplayName(rank)}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        // Info icon for current rank
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Tooltip(
            message: _getRankBenefits(rank),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            textStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.grey.shade500,
              size: 16,
            ),
          ),
        ),
        const Spacer(),
        if (remainingAmount > 0)
          Row(
            children: [
              Text(
                "Còn ${_formatCurrency(remainingAmount)}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              // Info icon for next rank
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Tooltip(
                  message: _getRankBenefits(nextRank),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  textStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.grey.shade500,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildProgressBar(String currentRank, String nextRank, double progress) {
    return Stack(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        Container(
          height: 6,
          width: MediaQuery.of(Get.context!).size.width * 0.8 * progress,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_getRankColor(currentRank), _getRankColor(nextRank)],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  Widget _buildRankLabels(String currentRank, String nextRank) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Tooltip(
            message: _getRankBenefits(currentRank),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            textStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
            ),
            child: Text(
              "Hạng ${_getRankDisplayName(currentRank)}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Tooltip(
            message: _getRankBenefits(nextRank),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            textStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
            ),
            child: Text(
              "Hạng ${_getRankDisplayName(nextRank)}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _getNextRank(String currentRank, int points, int totalOrders) {
    switch (currentRank.toLowerCase()) {
      case 'bronze':
        return 'silver';
      case 'silver':
        return 'gold';
      case 'gold':
        return 'diamond';
      case 'diamond':
        return 'diamond';
      default:
        return 'silver';
    }
  }

  double _calculateProgress(String currentRank, int points, int totalOrders) {
    switch (currentRank.toLowerCase()) {
      case 'bronze':
        final targetPoints = 1000;
        final targetOrders = 10;
        final progressPoints = points / targetPoints;
        final progressOrders = totalOrders / targetOrders;
        return (progressPoints + progressOrders) / 2;

      case 'silver':
        final targetPoints = 2000;
        final targetOrders = 20;
        final progressPoints = points / targetPoints;
        final progressOrders = totalOrders / targetOrders;
        return (progressPoints + progressOrders) / 2;

      case 'gold':
        final targetPoints = 5000;
        final targetOrders = 50;
        final progressPoints = points / targetPoints;
        final progressOrders = totalOrders / targetOrders;
        return (progressPoints + progressOrders) / 2;

      case 'diamond':
        return 1.0;

      default:
        return 0.0;
    }
  }

  int _getRemainingAmount(String currentRank, int points, int totalOrders) {
    switch (currentRank.toLowerCase()) {
      case 'bronze':
        final targetPoints = 1000;
        return (targetPoints - points).clamp(0, targetPoints);

      case 'silver':
        final targetPoints = 2000;
        return (targetPoints - points).clamp(0, targetPoints);

      case 'gold':
        final targetPoints = 5000;
        return (targetPoints - points).clamp(0, targetPoints);

      case 'diamond':
        return 0;

      default:
        return 1000;
    }
  }

  String _getRankDisplayName(String rank) {
    switch (rank.toLowerCase()) {
      case 'bronze':
        return 'Đồng';
      case 'silver':
        return 'Bạc';
      case 'gold':
        return 'Vàng';
      case 'diamond':
        return 'Kim Cương';
      default:
        return 'Đồng';
    }
  }

  String _formatCurrency(int amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫';
  }

  Color _getRankColor(String rank) {
    switch (rank.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'diamond':
        return const Color(0xFFB9F2FF);
      default:
        return Colors.green;
    }
  }

  String _getRankBenefits(String rank) {
    switch (rank.toLowerCase()) {
      case 'bronze':
        return '• Giảm giá 3% trên tất cả đơn hàng\n• Hỗ trợ ưu tiên\n• Tích điểm 1.2x\n• Miễn phí vận chuyển đơn từ 200k';
      case 'silver':
        return '• Giảm giá 5% trên tất cả đơn hàng\n• Hỗ trợ 24/7\n• Tích điểm 1.5x\n• Miễn phí vận chuyển đơn từ 150k\n• Quà tặng sinh nhật';
      case 'gold':
        return '• Giảm giá 8% trên tất cả đơn hàng\n• Hỗ trợ VIP\n• Tích điểm 2x\n• Miễn phí vận chuyển mọi đơn hàng\n• Quà tặng đặc biệt\n• Early access sản phẩm mới';
      case 'diamond':
        return '• Giảm giá 12% trên tất cả đơn hàng\n• Hỗ trợ chuyên gia\n• Tích điểm 3x\n• Miễn phí vận chuyển nhanh\n• Quà tặng cao cấp\n• Personal shopping assistant\n• Invitation-only events';
      default:
        return '• Giảm giá 3% trên tất cả đơn hàng\n• Hỗ trợ ưu tiên\n• Tích điểm 1.2x';
    }
  }
}