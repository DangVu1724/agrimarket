import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // TODO: Thay thế logic kiểm tra đăng nhập thực tế ở đây
    // Ví dụ: nếu chưa đăng nhập thì chuyển hướng về trang login
    // bool isLoggedIn = ...;
    // if (!isLoggedIn) return const RouteSettings(name: '/login');
    return null;
  }
}
