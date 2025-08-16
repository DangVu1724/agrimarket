import 'package:agrimarket/app/theme/app_text_styles.dart';
import 'package:agrimarket/data/services/address_service.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/buyer/search/view/categorylist.dart';
import 'package:agrimarket/features/buyer/search/view/filter_cuisine_widget.dart';
import 'package:agrimarket/features/buyer/search/view/filter_sort_widget.dart';
import 'package:agrimarket/features/buyer/search/view/search_result_item.dart';
import 'package:agrimarket/features/buyer/search/viewmodel/search_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SearchList extends StatelessWidget {
  final SearchVm searchVm;
  final PanelController panelController;

  SearchList({super.key, required this.searchVm, required this.panelController});

  final List<String> filters = ['Khuyến mãi', 'Lọc theo', 'Ẩm thực', 'Mới nhất'];

  @override
  Widget build(BuildContext context) {
    final BuyerVm vm = Get.find<BuyerVm>();

    return Expanded(
      child: SlidingUpPanel(
        controller: panelController,
        minHeight: 0,
        maxHeight: 300,
        backdropEnabled: true,
        backdropColor: Colors.black,
        backdropOpacity: 0.2,
        parallaxEnabled: true,
        parallaxOffset: 0.3,
        isDraggable: true,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        onPanelOpened: () => searchVm.isPanelOpen.value = true,
        onPanelClosed: () {
          searchVm.isPanelOpen.value = false;
        },
        panel: Obx(() {
          final selectedFilter = searchVm.selectedFilter.value;
          if (selectedFilter == 'Lọc theo') {
            return FilterSortWidget(panelController: panelController);
          } else if (selectedFilter == 'Ẩm thực') {
            return FilterCuisineWidget(panelController: panelController);
          } else {
            return const SizedBox.shrink();
          }
        }),
        body: Obx(() {
          final results = searchVm.filteredResults;
          final history = searchVm.history;
          final keyword = searchVm.searchText.value;
          final _ = searchVm.promotionOnly.value;
          final isSearching = searchVm.isSearching.value;

          if (isSearching) {
            return const Center(child: CircularProgressIndicator());
          }

          if (results.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final bool isActionPanel = filter == 'Lọc theo' || filter == 'Ẩm thực';
                        return Obx(() {
                          // Always read the reactive value to keep Obx subscribed
                          final String currentFilterValue = searchVm.selectedFilter.value;
                          bool isSelected;
                          if (!isActionPanel && filter == 'Khuyến mãi') {
                            isSelected = searchVm.promotionOnly.value;
                          } else if (!isActionPanel && filter == 'Mới nhất') {
                            isSelected = searchVm.newestOnly.value;
                          } else {
                            isSelected = !isActionPanel && currentFilterValue == filter;
                          }
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  filter,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (isActionPanel)
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 16,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: Colors.green,
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSelected ? Colors.green : Colors.grey[300]!),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            onSelected: (_) async {
                              final String currentFilter = searchVm.selectedFilter.value;

                              if (isActionPanel) {
                                // Set filter immediately, open panel slightly delayed for stability
                                searchVm.selectFilter(filter);
                                Future.microtask(() async {
                                  if (panelController.isAttached) {
                                    try {
                                      await panelController.open();
                                    } catch (_) {}
                                  }
                                });
                                return;
                              }

                              Future.microtask(() async {
                                if (filter == 'Khuyến mãi') {
                                  searchVm.togglePromotion();
                                } else if (filter == 'Mới nhất') {
                                  searchVm.toggleNewest();
                                } else {
                                  if (currentFilter == filter) {
                                    searchVm.clearFilter();
                                  } else {
                                    searchVm.selectFilter(filter);
                                  }
                                }

                                if (panelController.isAttached && panelController.isPanelOpen) {
                                  try {
                                    await panelController.close();
                                  } catch (_) {}
                                }
                              });
                            },
                          );
                        });
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemCount: filters.length,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: NotificationListener<UserScrollNotification>(
                      onNotification: (n) {
                        if (n.direction != ScrollDirection.idle &&
                            panelController.isAttached &&
                            panelController.isPanelOpen) {
                          panelController.close();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final store = results.keys.elementAt(index);
                          final products = results[store]!;
                          final buyer = vm.buyerData.value;
                          final addressService = AddressService();
                          final storeLatLng = store.getDefaultLatLng();
                          final buyerLatLng = buyer?.getDefaultLatLng();

                          if (storeLatLng == null || buyerLatLng == null) {
                            return SearchItem(store: store, products: products, distance: null, totalTime: null);
                          }

                          final distance = addressService.calculateDistance(
                            buyerLatLng[0],
                            buyerLatLng[1],
                            storeLatLng[0],
                            storeLatLng[1],
                          );
                          final formattedDistance = NumberFormat('#,##0.00', 'vi_VN').format(distance);
                          return FutureBuilder<int>(
                            future: addressService.getEstimatedTravelTime(
                              storeLatLng[0],
                              storeLatLng[1],
                              buyerLatLng[0],
                              buyerLatLng[1],
                            ),
                            builder: (context, snapshot) {
                              final estimatedTime = snapshot.hasData ? snapshot.data! : 0;
                              final int prepareTime = 15;
                              final int totalTime = prepareTime + estimatedTime;

                              return SearchItem(
                                store: store,
                                products: products,
                                distance: '$formattedDistance km',
                                totalTime: totalTime,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (keyword.isNotEmpty && results.isEmpty && !isSearching && searchVm.hasSearched.value) {
            // No results after applying current filters/sort -> keep filter chips visible and show bottom notice
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final bool isActionPanel = filter == 'Lọc theo' || filter == 'Ẩm thực';
                        return Obx(() {
                          final String currentFilterValue = searchVm.selectedFilter.value;
                          bool isSelected;
                          if (!isActionPanel && filter == 'Khuyến mãi') {
                            isSelected = searchVm.promotionOnly.value;
                          } else if (!isActionPanel && filter == 'Mới nhất') {
                            isSelected = searchVm.newestOnly.value;
                          } else {
                            isSelected = !isActionPanel && currentFilterValue == filter;
                          }
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  filter,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (isActionPanel)
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 16,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: Colors.green,
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSelected ? Colors.green : Colors.grey[300]!),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            onSelected: (_) async {
                              final String currentFilter = searchVm.selectedFilter.value;
                              if (isActionPanel) {
                                searchVm.selectFilter(filter);
                                Future.microtask(() async {
                                  if (panelController.isAttached) {
                                    try {
                                      await panelController.open();
                                    } catch (_) {}
                                  }
                                });
                                return;
                              }
                              Future.microtask(() async {
                                if (filter == 'Khuyến mãi') {
                                  searchVm.togglePromotion();
                                } else if (filter == 'Mới nhất') {
                                  searchVm.toggleNewest();
                                } else {
                                  if (currentFilter == filter) {
                                    searchVm.clearFilter();
                                  } else {
                                    searchVm.selectFilter(filter);
                                  }
                                }
                                if (panelController.isAttached && panelController.isPanelOpen) {
                                  try {
                                    await panelController.close();
                                  } catch (_) {}
                                }
                              });
                            },
                          );
                        });
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemCount: filters.length,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: Container()),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4D6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFE29A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF8A6D3B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Không có kết quả phù hợp với bộ lọc hiện tại. Thử thay đổi hoặc xoá bộ lọc.',
                            style: AppTextStyles.body.copyWith(fontSize: 13, color: const Color(0xFF8A6D3B)),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            searchVm.clearFilter();
                          },
                          child: const Text('Xoá bộ lọc'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (history.isNotEmpty && keyword.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryListWidget(),
                  const SizedBox(height: 16),
                  Text(
                    'Tìm kiếm gần đây',
                    style: AppTextStyles.headline.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: NotificationListener<UserScrollNotification>(
                      onNotification: (n) {
                        if (n.direction != ScrollDirection.idle &&
                            panelController.isAttached &&
                            panelController.isPanelOpen) {
                          panelController.close();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final keyword = history[index];
                          return ListTile(
                            leading: const Icon(Icons.history, color: Colors.grey),
                            title: Text(
                              keyword,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              searchVm.searchController.text = keyword;
                              searchVm.searchProducts(keyword);
                            },
                            trailing: IconButton(
                              onPressed: () {
                                searchVm.history.remove(keyword);
                                searchVm.saveHistory();
                              },
                              icon: const Icon(Icons.clear, color: Colors.grey),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CategoryListWidget(),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Hãy nhập từ khóa để tìm kiếm',
                      style: AppTextStyles.body.copyWith(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}
