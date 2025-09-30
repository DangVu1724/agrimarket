import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:flutter/material.dart';

class HistoryList extends StatelessWidget {
  final List<String> history;
  final SearchVm searchVm;
  const HistoryList({super.key, required this.history, required this.searchVm});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final keyword = history[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(keyword),
          onTap: () {
            searchVm.searchController.text = keyword;
            searchVm.searchProducts(keyword);
          },
        );
      },
    );
  }
}
