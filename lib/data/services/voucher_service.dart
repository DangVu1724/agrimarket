import 'dart:convert';

import 'package:agrimarket/core/constants/env_config.dart';
import 'package:agrimarket/data/models/user_vouchers.dart';
import 'package:agrimarket/data/models/vouchers_catalog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class VoucherService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken(true);
    }
    return null;
  }

  Future<List<UserVoucherModel>> getAllVouchers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_vouchers')
          .where('userId', isEqualTo: currentUser?.uid) 
          .get();

      final now = DateTime.now();

      // Chỉ lấy voucher chưa hết hạn
      return snapshot.docs.map((doc) {
        final voucher = UserVoucherModel.fromJson(doc.data());
        if (voucher.endDate.isAfter(now)) {
          return voucher;
        }
        return null;
      }).whereType<UserVoucherModel>().toList();
    } catch (e) {
      print('Error loading vouchers: $e');
      return [];
    }
  }

  Stream<List<VoucherModel>> getVouchersStream() {
    return FirebaseFirestore.instance
        .collection('vouchers')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => VoucherModel.fromJson(doc.data())).toList());
  }

  Stream<List<UserVoucherModel>> getUserVouchersStream() {
    return FirebaseFirestore.instance
        .collection('user_vouchers')
        .where('userId', isEqualTo: currentUser?.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserVoucherModel.fromJson(doc.data())).toList());
  }

  Future<VoucherModel?> getVoucherByUserVoucher(UserVoucherModel userVoucher) async {
    try {
      final snap = await FirebaseFirestore.instance.collection('vouchers').doc(userVoucher.voucherId).get();
      if (snap.exists) {
        return VoucherModel.fromJson(snap.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetching voucher: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> redeemVoucher(String voucherId) async {
  try {
    final idToken = await _getIdToken();
    final response = await http.post(
      Uri.parse("${EnvConfig.recoApiBaseUrl}/voucher/redeem"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
      body: jsonEncode({"voucherId": voucherId}),
    );

    final Map<String, dynamic> result = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Thành công
      return result;
    } else if (response.statusCode == 402 || response.statusCode == 410) {
      return result; // có { success: false, code: "...", message: "..." }
    } else {
      print("Failed to redeem voucher: ${response.statusCode}");
      return {
        "success": false,
        "code": "HTTP_ERROR",
        "message": "Có lỗi xảy ra. Vui lòng thử lại sau."
      };
    }
  } catch (e) {
    print("Exception redeem voucher: $e");
    return {
      "success": false,
      "code": "EXCEPTION",
      "message": e.toString(),
    };
  }
}

}
