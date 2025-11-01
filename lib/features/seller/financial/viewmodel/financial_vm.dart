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
    if (sellerHomeVm.store.value != null) {
      bindCommissionHistoryStream(sellerHomeVm.store.value!.storeId);
    }
  }

  Stream<List<CommissionModel>> commissionsStream(String storeId, String status) {
    return commissionService.getCommissionsByStatus(storeId, status);
  }

  Future<void> updateCommissionStatus(String commissionId, String newStatus) async {
    try {
      await commissionService.updateCommissionStatus(commissionId, newStatus, DateTime.now());
      print('✅ Đã cập nhật trạng thái commission: $newStatus');
    } catch (e) {
      print('❌ Lỗi khi cập nhật trạng thái commission: $e');
    }
  }

  Future<void> updateOrCreateCommissionForDeliveredOrder(OrderModel order) async {
    try {
      final storeId = order.storeId;
      final storeName = order.storeName ?? "Không rõ";
      final DateTime deliveredAt = order.deliveredAt ?? DateTime.now();
      final String dateKey = DateFormat('yyyy-MM-dd').format(deliveredAt);

      // Lấy commission pending trong ngày này
      final existingCommissions = await commissionService.getCommissionsByDateAndStatus(storeId, dateKey, 'pending');

      if (existingCommissions.isNotEmpty) {
        // 🔹 Đã có commission pending → cập nhật
        final existing = existingCommissions.first;

        final newOrderAmount = existing.orderAmount + order.totalPrice;
        final newCommissionAmount = newOrderAmount * 0.1;

        final updatedOrderIds = List<String>.from(existing.orderIds)..add(order.orderId);

        final updatedCommission = existing.copyWith(
          orderIds: updatedOrderIds,
          orderAmount: newOrderAmount,
          commissionAmount: newCommissionAmount,
          updatedAt: DateTime.now(),
        );

        await commissionService.updateCommission(updatedCommission);

        print('✅ Đã cập nhật commission pending cho ngày $dateKey');
      } else {
        // 🔹 Chưa có commission hoặc commission cũ đã thanh toán → tạo mới
        final commissionId = const Uuid().v4();
        final commission = CommissionModel(
          commissionId: commissionId,
          storeId: storeId,
          storeName: storeName,
          orderIds: [order.orderId],
          orderAmount: order.totalPrice,
          commissionAmount: order.totalPrice * 0.1,
          orderDate: deliveredAt,
          dueDate: deliveredAt.add(const Duration(days: 7)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: 'pending',
        );

        await commissionService.createCommission(commission);
        print('🆕 Tạo commission mới (pending) cho ngày $dateKey');
      }

      // 🔹 Đánh dấu order đã tính commission
      await sellerOrdersVm.updateOrdersCommissionPaidStatus([order.orderId], true);
    } catch (e) {
      print('❌ Lỗi khi cập nhật hoặc tạo commission: $e');
    }
  }

  void bindCommissionHistoryStream(String storeId) {
    commissionService.getCommissionsByStatus(storeId, 'paid').listen((data) => commissionHistoryList.value = data);
  }
}
