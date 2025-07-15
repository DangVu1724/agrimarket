import 'package:agrimarket/data/models/commission.dart';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/data/services/commision_service.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:agrimarket/features/seller/orders/viewmodel/seller_orders_vm.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CommissionVm extends GetxController {
  final SellerOrdersVm sellerOrdersVm = Get.put(SellerOrdersVm());
  final SellerHomeVm sellerHomeVm = Get.put(SellerHomeVm());
  final CommissionService commissionService = Get.put(CommissionService());
  final RxList<CommissionModel> commissionList = <CommissionModel>[].obs;
  final RxList<CommissionModel> commissionHistoryList = <CommissionModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getCommission();
    getCommissionHistory(sellerHomeVm.store.value!.storeId);
  }

  Future<void> getCommission() async {
    isLoading.value = true;
    final List<OrderModel> unCommissionPaidOrdersList = sellerOrdersVm.getUnCommissionPaidOrders();
    Map<String, List<OrderModel>> unCommissionPaidOrdersMap = {};

    for (var order in unCommissionPaidOrdersList) {
      final String dateKey =
          order.deliveredAt != null
              ? DateFormat('yyyy-MM-dd').format(order.deliveredAt!)
              : DateFormat('yyyy-MM-dd').format(order.updatedAt!);

      if (unCommissionPaidOrdersMap.containsKey(dateKey)) {
        unCommissionPaidOrdersMap[dateKey]!.add(order);
      } else {
        unCommissionPaidOrdersMap[dateKey] = [order];
      }
    }

    // Tạo danh sách commission từ các đơn hàng chưa thanh toán commission
    // Nhưng không lưu vào database, chỉ để hiển thị
    commissionList.value =
        unCommissionPaidOrdersMap.values.map((e) {
          final double totalPrice = e.fold(0, (sum, order) => sum + order.totalPrice);
          final double commissionAmount = totalPrice * 0.1;
          final String commissionId = const Uuid().v4();
          final DateTime orderDate = e.first.updatedAt!;

          return CommissionModel(
            orderIds: e.map((e) => e.orderId).toList(),
            orderDate: orderDate,
            dueDate: orderDate.add(const Duration(days: 7)),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            commissionId: commissionId,
            storeId: e.first.storeId,
            storeName: e.first.storeName!,
            orderAmount: totalPrice,
            commissionAmount: commissionAmount,
            status: 'pending',
          );
        }).toList();

    commissionList.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    isLoading.value = false;
  }

  Future<void> createCommission(
    String commissionId,
    String storeId,
    String storeName,
    double orderAmount,
    double commissionAmount,
    String status,
    List<String> orderIds,
    DateTime orderDate,
    DateTime dueDate,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? paidDate,
  ) async {
    try {
      // Tạo commission
      await commissionService.createCommission(
        CommissionModel(
          commissionId: commissionId,
          storeId: storeId,
          storeName: storeName,
          orderAmount: orderAmount,
          commissionAmount: commissionAmount,
          status: status,
          orderIds: orderIds,
          orderDate: orderDate,
          dueDate: dueDate,
          createdAt: createdAt,
          updatedAt: updatedAt,
          paidDate: paidDate,
        ),
      );

      // Cập nhật trạng thái isCommissionPaid cho các order liên quan
      await sellerOrdersVm.updateOrdersCommissionPaidStatus(orderIds, true);

      await getCommission();
    } catch (e) {
      throw Exception('Failed to create commission: $e');
    }
  }

  Future<void> getCommissionHistory(String? storeId) async {
    try {
      final paidCommissions = await commissionService.getCommissionsByStatus(storeId!, 'paid');
      commissionHistoryList.value = paidCommissions;
    } catch (e) {
      // Fallback to local list if database fails
      commissionHistoryList.value = commissionList.where((e) => e.status == 'paid').toList();
    }
  }
}
