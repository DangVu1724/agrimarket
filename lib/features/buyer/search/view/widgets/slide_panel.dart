import 'package:agrimarket/features/buyer/search/viewmodel/filter_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlidePanel extends StatelessWidget {
  const SlidePanel({super.key, required this.filterVm});
  final FilterVm filterVm;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.7;
    final height = MediaQuery.of(context).size.height * 0.8;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Text("Lọc sản phẩm", style: TextStyle(fontSize: 20)),
                Divider(),
                Text("Khoảng giá"),
                SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: filterVm.fromController,
                        decoration: const InputDecoration(
                          labelText: "Từ",
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text("_"),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: filterVm.toController,
                        decoration: const InputDecoration(
                          labelText: "Đến",
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                Divider(),
                Text("Cửa hàng"),
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 3.6,
                        ),
                    itemCount: filterVm.filterResults.length,
                    itemBuilder: (context, index) {
                      final storeName =
                          filterVm.filterResults[index].store!.name;

                      return Obx(() {
                        final isSelected = filterVm.store.value == storeName;
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color:
                                isSelected
                                    ? Colors.lightGreenAccent.shade100
                                    : Colors.white,
                          ),
                          child: TextButton(
                            child: Text(
                              storeName,
                              style: TextStyle(color: Colors.green),
                            ),
                            onPressed: () {
                              filterVm.store.value = storeName;
                            },
                          ),
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[300],
                      ),
                      onPressed: () {
                        filterVm.store.value = '';
                        filterVm.from.value = 0.0;
                        filterVm.to.value = double.infinity;
                        filterVm.fromController.clear();
                        filterVm.toController.clear();
                        filterVm.removeKeyword("store");
                        filterVm.removeKeyword("range");
                        Navigator.of(context).pop();
                      },
                      child: const Text("Xóa lọc", style: TextStyle(color: Colors.white),),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[500]),
                      onPressed: () {
                        if (filterVm.store.value != '') {
                          filterVm.filterKeywords.add("store");
                        }
                        filterVm.setRange();
                        if (filterVm.from.value != 0.0 ||
                            filterVm.to.value != double.infinity) {
                          filterVm.filterKeywords.add("range");
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text("Áp dụng", style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showSlidePanel(BuildContext context, FilterVm filterVm) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false, // giữ nền trang trước thấy mờ
      barrierColor: Colors.black54, // nền tối mờ
      pageBuilder:
          (context, animation, secondaryAnimation) =>
              SlidePanel(filterVm: filterVm),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    ),
  );
}
