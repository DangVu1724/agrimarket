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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!revenueVm.isRealtimeEnabled.value) {
        revenueVm.startRealtimeUpdates();
      }
    });

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(revenueVm),
          
          // Time period selector
          _buildTimePeriodSelector(revenueVm),
          
          // Chart - Chiếm không gian còn lại
          Expanded(
            child: _buildChart(revenueVm),
          ),
          
          // Footer info
          _buildFooter(revenueVm),
        ],
      ),
    );
  }

  Widget _buildHeader(RevenueVm revenueVm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up, color: Colors.green.shade600, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tổng quan doanh thu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total revenue
              Obx(() {
                final totalRevenue = revenueVm.getTotalRevenue();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng doanh thu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatNumber(totalRevenue),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                );
              }),
              
              // Realtime control
              _buildRealtimeControl(revenueVm),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodSelector(RevenueVm revenueVm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildTimePeriodButton('Tuần', 0, revenueVm),
          const SizedBox(width: 8),
          _buildTimePeriodButton('Tháng', 1, revenueVm),
          const SizedBox(width: 8),
          _buildTimePeriodButton('Năm', 2, revenueVm),
        ],
      ),
    );
  }

  Widget _buildTimePeriodButton(String text, int index, RevenueVm revenueVm) {
    return Obx(() {
      final isSelected = revenueVm.selectedPeriodIndex.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => revenueVm.selectedPeriodIndex.value = index,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green.shade600 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.green.shade600 : Colors.grey.shade200,
              ),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRealtimeControl(RevenueVm revenueVm) {
    return Obx(() {
      return Container(
        constraints: const BoxConstraints(maxWidth: 180),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: revenueVm.isRealtimeEnabled.value ? Colors.green : Colors.grey,
                boxShadow: revenueVm.isRealtimeEnabled.value
                    ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                revenueVm.isRealtimeEnabled.value ? 'Đang cập nhật' : 'Đã dừng',
                style: TextStyle(
                  fontSize: 12,
                  color: revenueVm.isRealtimeEnabled.value ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            // Toggle button
            GestureDetector(
              onTap: revenueVm.toggleRealtimeUpdates,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: revenueVm.isRealtimeEnabled.value 
                      ? Colors.orange.shade50 
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: revenueVm.isRealtimeEnabled.value 
                        ? Colors.orange.shade300 
                        : Colors.green.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      revenueVm.isRealtimeEnabled.value ? Icons.pause : Icons.play_arrow,
                      size: 16,
                      color: revenueVm.isRealtimeEnabled.value ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      revenueVm.isRealtimeEnabled.value ? 'Tạm dừng' : 'Bật live',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: revenueVm.isRealtimeEnabled.value ? Colors.orange : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChart(RevenueVm revenueVm) {
    return Obx(() {
      final filteredData = revenueVm.getFilteredData();

      if (filteredData.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('Không có dữ liệu doanh thu', 
                     style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      }

      final spots = filteredData.asMap().entries.map((entry) {
        int index = entry.key;
        double y = (entry.value['revenue'] as num).toDouble();
        return FlSpot(index.toDouble(), y);
      }).toList();

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.green.shade600,
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                barWidth: 4,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.green.shade600,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade600.withOpacity(0.3),
                      Colors.green.shade600.withOpacity(0.1),
                      Colors.green.shade600.withOpacity(0.0)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                aboveBarData: BarAreaData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < filteredData.length) {
                      final date = filteredData[value.toInt()]['date'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _formatDateLabel(date, revenueVm.selectedPeriodIndex.value),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  interval: _calculateTitleInterval(filteredData.length),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  interval: _calculateInterval(spots),
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        _formatNumber(value),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _calculateInterval(spots),
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.shade100,
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
                left: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            minY: 0,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                maxContentWidth: 200,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final date = filteredData[spot.x.toInt()]['date'];
                    final revenue = spot.y;
                    return LineTooltipItem(
                      '${_formatDateTooltip(date, revenueVm.selectedPeriodIndex.value)}\nDoanh thu: ${_formatNumber(revenue)}',
                      const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                    );
                  }).toList();
                },
              ),
              handleBuiltInTouches: true,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFooter(RevenueVm revenueVm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                'Dữ liệu được cập nhật mỗi 30 giây',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
          Obx(() {
            return Text(
              'Cập nhật lúc: ${DateFormat('HH:mm:ss').format(revenueVm.lastUpdated.value)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            );
          }),
        ],
      ),
    );
  }

  double _calculateTitleInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 15) return 2;
    if (dataLength <= 30) return 3;
    return 5;
  }

  String _formatDateLabel(String date, int periodIndex) {
    try {
      final dateTime = DateFormat('dd/MM/yyyy').parse(date);
      switch (periodIndex) {
        case 0: // Tuần
          return 'T${DateFormat('d').format(dateTime)}'; // T2, T3, etc.
        case 1: // Tháng
          return DateFormat('dd/MM').format(dateTime); // 15/12
        case 2: // Năm
          return DateFormat('MM/yyyy').format(dateTime); // 12/2023
        default:
          return date;
      }
    } catch (e) {
      return date;
    }
  }

  String _formatDateTooltip(String date, int periodIndex) {
    try {
      final dateTime = DateFormat('dd/MM/yyyy').parse(date);
      switch (periodIndex) {
        case 0: // Tuần
          return DateFormat('EEE, dd/MM/yyyy').format(dateTime);
        case 1: // Tháng
          return DateFormat('dd/MM/yyyy').format(dateTime);
        case 2: // Năm
          return DateFormat('MM/yyyy').format(dateTime);
        default:
          return date;
      }
    } catch (e) {
      return date;
    }
  }

  double _calculateInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1000;
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    if (maxY == 0) return 1000;
    return (maxY / 4).ceilToDouble();
  }

  String _formatNumber(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}T';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}Tr';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}