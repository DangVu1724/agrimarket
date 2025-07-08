import 'package:agrimarket/data/models/order.dart';

class RevenueService {
  static const double APP_COMMISSION_RATE = 0.9; // 10%

  double getDailyRevenue(List<OrderModel> orders, DateTime date) {
    return orders
        .where(
          (order) =>
              order.status == 'delivered' &&
              order.updatedAt != null &&
              order.updatedAt!.day == date.day &&
              order.updatedAt!.month == date.month &&
              order.updatedAt!.year == date.year,
        )
        .fold(0, (sum, order) => sum + order.totalPrice);
  }

  double getYesterdayRevenue(List<OrderModel> orders, DateTime date) {
    final yesterday = date.subtract(const Duration(days: 1));
    return orders
        .where(
          (order) =>
              order.status == 'delivered' &&
              order.updatedAt != null &&
              order.updatedAt!.day == yesterday.day &&
              order.updatedAt!.month == yesterday.month &&
              order.updatedAt!.year == yesterday.year,
        )
        .fold(0, (sum, order) => sum + order.totalPrice);
  }

  double getMonthlyRevenue(List<OrderModel> orders, DateTime date) {
    return orders
        .where(
          (order) =>
              order.status == 'delivered' &&
              order.updatedAt != null &&
              order.updatedAt!.month == date.month &&
              order.updatedAt!.year == date.year,
        )
        .fold(0, (sum, order) => sum + order.totalPrice);
  }

  double getYearlyRevenue(List<OrderModel> orders, DateTime date) {
    return orders
        .where((order) => order.status == 'delivered' && order.updatedAt != null && order.updatedAt!.year == date.year)
        .fold(0, (sum, order) => sum + order.totalPrice);
  }

  // ========== APP COMMISSION METHODS ==========

  // Commission hôm nay
  double getDailyCommission(List<OrderModel> orders, DateTime date) {
    return getDailyRevenue(orders, date) * APP_COMMISSION_RATE;
  }

  // Commission hôm qua
  double getYesterdayCommission(List<OrderModel> orders, DateTime date) {
    return getYesterdayRevenue(orders, date) * APP_COMMISSION_RATE;
  }

  // Commission tháng này
  double getMonthlyCommission(List<OrderModel> orders, DateTime date) {
    return getMonthlyRevenue(orders, date) * APP_COMMISSION_RATE;
  }

  // Commission năm này
  double getYearlyCommission(List<OrderModel> orders, DateTime date) {
    return getYearlyRevenue(orders, date) * APP_COMMISSION_RATE;
  }

  // Commission từ một đơn hàng cụ thể
  double getOrderCommission(OrderModel order) {
    return order.totalPrice * APP_COMMISSION_RATE;
  }

  // Doanh thu thực tế của seller (sau khi trừ commission)
  double getSellerNetRevenue(List<OrderModel> orders, DateTime date) {
    return getDailyRevenue(orders, date) * (1 - APP_COMMISSION_RATE);
  }

  // Tổng commission từ tất cả đơn hàng
  double getTotalCommission(List<OrderModel> orders) {
    return orders
        .where((order) => order.status == 'delivered')
        .fold(0, (sum, order) => sum + getOrderCommission(order));
  }
}
