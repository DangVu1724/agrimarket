import 'package:agrimarket/app/theme/app_colors.dart';
import 'package:agrimarket/data/services/revenue_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueTable extends StatefulWidget {
  final List<Map<String, dynamic>> revenueList;

  const RevenueTable({super.key, required this.revenueList});

  @override
  State<RevenueTable> createState() => _RevenueTableState();
}

class _RevenueTableState extends State<RevenueTable> {
  static const int itemPerPage = 7;
  int currentPage = 0;
  List<Map<String, dynamic>> getCurrentPageData() {
    final startIndex = currentPage * itemPerPage;
    final endIndex =
        (startIndex + itemPerPage > widget.revenueList.length) ? widget.revenueList.length : startIndex + itemPerPage;

    return widget.revenueList.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final currentPageData = getCurrentPageData();
    final totalPages = (widget.revenueList.length / itemPerPage).ceil();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            dataTextStyle: const TextStyle(fontWeight: FontWeight.normal),
            sortAscending: true,
            columns: const [
              DataColumn(label: Text('Ngày')),
              DataColumn(label: Text('Doanh thu')),
              DataColumn(label: Text('Tiền hoa hồng')),
            ],
            rows:
                currentPageData
                    .map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Text(item['date'])),
                          DataCell(Text(formatter.format(item['revenue']))),
                          DataCell(Text(formatter.format(item['revenue'] * (1 - RevenueService.APP_COMMISSION_RATE)))),
                        ],
                      );
                    })
                    .toList()
                    .reversed
                    .toList(),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: List.generate(totalPages, (index) {
              final isSelected = index == currentPage;
              return ElevatedButton(
                onPressed: () => setState(() => currentPage = index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade100,
                  foregroundColor: isSelected ? Colors.white : AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
