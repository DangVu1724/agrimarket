import 'package:agrimarket/features/seller/revenue/viewmodel/revenue_vm.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    final RevenueVm revenueVm = Get.find();

    // Bắt đầu realtime updates khi chart được build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!revenueVm.isRealtimeEnabled.value) {
        revenueVm.startRealtimeUpdates();
      }
    });

    return Obx(() {
      if (revenueVm.revenueList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = revenueVm.revenueList;

      // Create data points for the line chart
      final spots =
          data.asMap().entries.map((entry) {
            int index = entry.key;
            double y = (entry.value['revenue'] as num).toDouble();
            return FlSpot(index.toDouble(), y);
          }).toList();

      return Column(
        children: [
          // Header với nút toggle realtime
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green.shade600, size: 20),
                    const SizedBox(width: 8),
                    const Text('Doanh Thu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    // Status indicator
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: revenueVm.isRealtimeEnabled.value ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      revenueVm.isRealtimeEnabled.value ? 'Live' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: revenueVm.isRealtimeEnabled.value ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Toggle button
                    GestureDetector(
                      onTap: revenueVm.toggleRealtimeUpdates,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: revenueVm.isRealtimeEnabled.value ? Colors.green.shade100 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: revenueVm.isRealtimeEnabled.value ? Colors.green.shade300 : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              revenueVm.isRealtimeEnabled.value ? Icons.pause : Icons.play_arrow,
                              size: 16,
                              color: revenueVm.isRealtimeEnabled.value ? Colors.green.shade700 : Colors.grey.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              revenueVm.isRealtimeEnabled.value ? 'Pause' : 'Live',
                              style: TextStyle(
                                fontSize: 12,
                                color: revenueVm.isRealtimeEnabled.value ? Colors.green.shade700 : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Chart container
          Container(
            height: 300,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.green.shade600,
                    barWidth: 4,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter:
                          (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 5,
                            color: Colors.green.shade800,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [Colors.green.shade600.withOpacity(0.3), Colors.green.shade600.withOpacity(0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  // Only show X and Y axes
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          final date = data[value.toInt()]['date'];
                          // Show only month-day in a smaller, cleaner font
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              date,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _calculateInterval(spots), // Dynamic interval
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatNumber(value),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false), // Remove grid
                borderData: FlBorderData(show: false), // Remove border
                minY: 0,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    // tooltipBgColor: Colors.green.shade800.withOpacity(0.8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = data[spot.x.toInt()]['date'];
                        return LineTooltipItem(
                          'Ngày: $date\nDoanh thu: ${_formatNumber(spot.y)}',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
          // Info text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cập nhật mỗi 30 giây', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                Text(
                  'Cập nhật lúc: ${DateFormat('HH:mm:ss').format(revenueVm.lastUpdated.value)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // Calculate dynamic interval for Y-axis based on data range
  double _calculateInterval(List<FlSpot> spots) {
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    return maxY / 5;
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
