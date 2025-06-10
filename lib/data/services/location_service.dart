import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  Future<void> fetchProvinces(RxList<Map<String, dynamic>> provinces) async {
    try {
      final response = await http
          .get(Uri.parse('https://provinces.open-api.vn/api/p/'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        provinces.value = data
            .map((item) => {
                  'code': item['code'].toString(),
                  'name': item['name'],
                })
            .toList();
        if (provinces.isEmpty) {
          Get.snackbar('Lỗi', 'Danh sách tỉnh/thành phố rỗng');
        }
      } else {
        Get.snackbar('Lỗi', 'Không thể tải danh sách tỉnh/thành phố');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi tải tỉnh/thành phố: $e');
    }
  }

  Future<void> fetchDistricts(
      String provinceCode, RxList<Map<String, dynamic>> districts) async {
    if (provinceCode.isEmpty) {
      districts.clear();
      return;
    }
    try {
      final response = await http
          .get(Uri.parse('https://provinces.open-api.vn/api/p/$provinceCode?depth=2'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        districts.value = (data['districts'] as List)
            .map((item) => {
                  'code': item['code'].toString(),
                  'name': item['name'],
                })
            .toList();
        if (districts.isEmpty) {
          Get.snackbar('Lỗi', 'Danh sách quận/huyện rỗng');
        }
      } else {
        Get.snackbar('Lỗi', 'Không thể tải danh sách quận/huyện');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi tải quận/huyện: $e');
      districts.clear();
    }
  }

  Future<void> fetchWards(
      String districtCode, RxList<Map<String, dynamic>> wards) async {
    if (districtCode.isEmpty) {
      wards.clear();
      return;
    }
    try {
      final response = await http
          .get(Uri.parse('https://provinces.open-api.vn/api/d/$districtCode?depth=2'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        wards.value = (data['wards'] as List)
            .map((item) => {
                  'code': item['code'].toString(),
                  'name': item['name'],
                })
            .toList();
        if (wards.isEmpty) {
          Get.snackbar('Thông báo', 'Không có phường/xã nào cho quận/huyện này');
        }
      } else {
        Get.snackbar('Lỗi', 'Không thể tải danh sách phường/xã');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi tải phường/xã: $e');
      wards.clear();
    }
  }
}