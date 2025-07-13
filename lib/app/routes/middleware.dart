import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final user = FirebaseAuth.instance.currentUser;
    final box = Hive.box('storeCache');
    final userData = box.get('user');

    // Routes không cần authentication
    final publicRoutes = [
      AppRoutes.splash,
      AppRoutes.dashboard,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.emailVerify,
      AppRoutes.roleSelection,
      AppRoutes.resetPassword,
    ];

    // Nếu route hiện tại là public, cho phép truy cập
    if (publicRoutes.contains(route)) {
      return null;
    }

    // Kiểm tra đăng nhập
    if (user == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // Kiểm tra email verification
    if (!user.emailVerified && route != AppRoutes.emailVerify) {
      return const RouteSettings(name: AppRoutes.emailVerify);
    }

    // Kiểm tra role nếu đã có user data
    if (userData != null) {
      final role = userData['role'] as String?;

      // Routes chỉ dành cho buyer
      final buyerRoutes = [
        AppRoutes.buyerHome,
        AppRoutes.buyerHomeScreen,
        AppRoutes.cart,
        AppRoutes.buyerOrders,
        AppRoutes.buyerSearch,
        AppRoutes.buyerProfile,
        AppRoutes.buyerAccount,
        AppRoutes.buyerAddress,
        AppRoutes.favourite,
        AppRoutes.store,
        AppRoutes.buyerProductDetail,
        AppRoutes.buyerOrderDetail,
        AppRoutes.checkOut,
        AppRoutes.discountCode,
        AppRoutes.paymentMethod,
        AppRoutes.storePromotionList,
        AppRoutes.addAddress,
      ];

      // Routes chỉ dành cho seller
      final sellerRoutes = [
        AppRoutes.sellerHome,
        AppRoutes.sellerHomeScreen,
        AppRoutes.sellerOrderList,
        AppRoutes.sellerMenu,
        AppRoutes.sellerPromotions,
        AppRoutes.sellerFinance,
        AppRoutes.sellerStaff,
        AppRoutes.sellerProduct,
        AppRoutes.sellerChat,
        AppRoutes.storeInfo,
        AppRoutes.sellerProductDetail,
        AppRoutes.sellerUpdateProduct,
        AppRoutes.sellerCreateProduct,
        AppRoutes.sellerCreatePromotion,
        AppRoutes.sellerCreateDiscountCode,
        AppRoutes.adminPromotion,
        AppRoutes.settings,
        AppRoutes.revenue,
        AppRoutes.sellerFinancial,
        AppRoutes.createStoreInfo,
        AppRoutes.createStoreAddress,
        AppRoutes.sellerProfile,
      ];

      // Kiểm tra quyền truy cập theo role
      if (role == 'buyer' && sellerRoutes.contains(route)) {
        return const RouteSettings(name: AppRoutes.buyerHome);
      }

      if (role == 'seller' && buyerRoutes.contains(route)) {
        return const RouteSettings(name: AppRoutes.sellerHome);
      }
    }

    return null;
  }
}

class RoleMiddleware extends GetMiddleware {
  final String requiredRole;

  RoleMiddleware({required this.requiredRole});

  @override
  RouteSettings? redirect(String? route) {
    final box = Hive.box('storeCache');
    final userData = box.get('user');

    if (userData == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final role = userData['role'] as String?;

    if (role != requiredRole) {
      if (role == 'buyer') {
        return const RouteSettings(name: AppRoutes.buyerHome);
      } else if (role == 'seller') {
        return const RouteSettings(name: AppRoutes.sellerHome);
      } else {
        return const RouteSettings(name: AppRoutes.roleSelection);
      }
    }

    return null;
  }
}
