import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/providers/firestore_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrimarket/app/routes/app_routes.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CreateStoreViewModel extends GetxController {
  final FirestoreProvider _firestoreProvider = FirestoreProvider();
  final formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final provinceController = TextEditingController();
  final districtController = TextEditingController();
  final wardController = TextEditingController();
  final streetController = TextEditingController();
  final houseNumberController = TextEditingController();

  // Danh sách dữ liệu
  final provinces = <Map<String, dynamic>>[].obs;
  final districts = <Map<String, dynamic>>[].obs;
  final wards = <Map<String, dynamic>>[].obs;
  final categories = <String>[].obs;
  final availableCategories = ['Trái cây', 'Rau củ', 'Thực phẩm chế biến', 'Ngũ cốc - Hạt','Trứng','Thịt' , 'Thuỷ hải sản', 'Sữa và sản phẩm từ sữa', 'Đặc sản vùng miền'].obs;

  // Trạng thái
  final isLoadingProvinces = RxBool(false);
  final isLoadingDistricts = RxBool(false);
  final isLoadingWards = RxBool(false);
  final isLoading = RxBool(false);
  final selectedProvinceCode = RxnString();
  final selectedDistrictCode = RxnString();
  final selectedWardCode = RxnString();
  final businessLicenseFile = Rxn<XFile>();
  final foodSafetyCertificateFile = Rxn<XFile>();

  @override
  void onInit() {
    super.onInit();
    fetchProvinces();
    provinceController.addListener(_onProvinceChanged);
    districtController.addListener(onDistrictChanged);

  }

  Future<void> fetchProvinces() async {
    try {
      isLoadingProvinces.value = true;
      final response = await http.get(Uri.parse('https://provinces.open-api.vn/api/p/')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          provinces.value = data.map<Map<String, dynamic>>((item) => {
                'code': item['code'].toString(), 
                'name': item['name'],
              }).toList();
        } else {
          Get.snackbar('Lỗi', 'Danh sách tỉnh/thành phố rỗng');
        }
      } else {
        Get.snackbar('Lỗi', 'Không thể tải danh sách tỉnh/thành phố');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi tải tỉnh/thành phố: $e');
    } finally {
      isLoadingProvinces.value = false;
    }
  }

  void _onProvinceChanged() {
    final selected = provinces.firstWhereOrNull((p) => p['name'] == provinceController.text);
    if (selected != null && selected['code'] != null) {
      selectedProvinceCode.value = selected['code'].toString();
      selectedDistrictCode.value = null;
      selectedWardCode.value = null;
      districts.clear();
      wards.clear();
      districtController.clear();
      wardController.clear();
      _updateDistricts(selectedProvinceCode.value!);
    } else {
      selectedProvinceCode.value = null;
      selectedDistrictCode.value = null;
      selectedWardCode.value = null;
      districts.clear();
      wards.clear();
      districtController.clear();
      wardController.clear();
      update();
    }
  }

  Future<void> _updateDistricts(String provinceCode) async {
    if (provinceCode.isEmpty) {
      districts.clear();
      wards.clear();
      districtController.clear();
      wardController.clear();
      selectedDistrictCode.value = null;
      selectedWardCode.value = null;
      update();
      return;
    }
    try {
      isLoadingDistricts.value = true;
      final response = await http.get(Uri.parse('https://provinces.open-api.vn/api/p/$provinceCode?depth=2')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['districts'] != null && data['districts'] is List) {
          districts.value = data['districts'].map<Map<String, dynamic>>((item) => {
                'code': item['code'].toString(), 
                'name': item['name'],
              }).toList();
          wards.clear();
          wardController.clear();
          selectedWardCode.value = null;
        } else {
          Get.snackbar('Lỗi', 'Danh sách quận/huyện rỗng');
          districts.clear();
          wards.clear();
          districtController.clear();
          wardController.clear();
          selectedDistrictCode.value = null;
          selectedWardCode.value = null;
        }
      } else {
        Get.snackbar('Lỗi', 'Không thể tải danh sách quận/huyện');
        districts.clear();
        wards.clear();
        districtController.clear();
        wardController.clear();
        selectedDistrictCode.value = null;
        selectedWardCode.value = null;
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi tải quận/huyện: $e');
      districts.clear();
      wards.clear();
      districtController.clear();
      wardController.clear();
      selectedDistrictCode.value = null;
      selectedWardCode.value = null;
    } finally {
      isLoadingDistricts.value = false;
      update();
    }
  }

  void onDistrictChanged() {
    if (districts.isEmpty) {
      selectedDistrictCode.value = null;
      selectedWardCode.value = null;
      wards.clear();
      wardController.clear();
      update();
      return;
    }
    final selected = districts.firstWhereOrNull((d) => d['name'] == districtController.text);
    if (selected != null && selected['code'] != null) {
      selectedDistrictCode.value = selected['code'].toString();
      selectedWardCode.value = null;
      _updateWards(selected['code'].toString());
    } else {
      selectedDistrictCode.value = null;
      selectedWardCode.value = null;
      wards.clear();
      wardController.clear();
      Get.snackbar('Lỗi', 'Quận/huyện không hợp lệ');
      update();
    }
  }

  Future<void> _updateWards(String districtCode) async {
    if (districtCode.isEmpty) {
      wards.clear();
      wardController.clear();
      selectedWardCode.value = null;
      isLoadingWards.value = false;
      update();
      return;
    }
    try {
      isLoadingWards.value = true;
      final response = await http.get(Uri.parse('https://provinces.open-api.vn/api/d/$districtCode?depth=2')).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['wards'] != null && data['wards'] is List) {
          wards.value = data['wards'].map<Map<String, dynamic>>((item) => {
                'code': item['code'].toString(),
                'name': item['name'],
              }).toList();
          if (wards.isEmpty) {
            Get.snackbar('Thông báo', 'Không có phường/xã nào cho quận/huyện này');
          }
        } else {
          Get.snackbar('Lỗi', 'Danh sách phường/xã rỗng');
          wards.clear();
          wardController.clear();
          selectedWardCode.value = null;
        }
      } else {
        Get.snackbar('Lỗi', 'Không thể tải danh sách phường/xã');
        wards.clear();
        wardController.clear();
        selectedWardCode.value = null;
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi tải phường/xã: $e');
      wards.clear();
      wardController.clear();
      selectedWardCode.value = null;
    } finally {
      isLoadingWards.value = false;
      update();
    }
  }

  void onWardChanged() {
    final selected = wards.firstWhereOrNull((w) => w['name'] == wardController.text);
    if (selected != null && selected['code'] != null) {
      selectedWardCode.value = selected['code'].toString();
    } else {
      selectedWardCode.value = null;
      Get.snackbar('Lỗi', 'Phường/xã không hợp lệ');
    }
  }

  void toggleCategory(String category) {
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
  }


  Future<void> pickImage({required bool isBusinessLicense, bool fromCamera = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        if (isBusinessLicense) {
          businessLicenseFile.value = image;
        } else {
          foodSafetyCertificateFile.value = image;
        }
        print('${isBusinessLicense ? 'Business License' : 'Food Safety Certificate'} selected: ${image.path}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn ảnh: $e');
    }
  }

  void clearImage(bool isBusinessLicense) {
    if (isBusinessLicense) {
      businessLicenseFile.value = null;
    } else {
      foodSafetyCertificateFile.value = null;
    }
  }

  Future<String?> _uploadImageToGitHub(XFile? file, String storeId, String type) async {
  if (file == null) return null;
  try {
    print('Starting upload to GitHub for $type, storeId: $storeId');
    final bytes = await file.readAsBytes();
    print('File size: ${bytes.length} bytes');
    final base64Image = base64Encode(bytes);
    final fileName = '$type-$storeId-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$storeId/certificates/$fileName';

    if (!dotenv.isInitialized) {
      throw Exception('dotenv not initialized. Check .env file and main.dart');
    }

    final token = dotenv.env['GITHUB_TOKEN'];
    final owner = dotenv.env['GITHUB_OWNER'];
    final repo = dotenv.env['GITHUB_REPO'];

    if (token == null || owner == null || repo == null) {
      throw Exception('GitHub configuration missing: token=$token, owner=$owner, repo=$repo');
    }

    // Kiểm tra xem file đã tồn tại chưa, lấy sha nếu có
    final getUri = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');
    String? sha;
    final getResponse = await http.get(getUri, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github.v3+json',
    });
    if (getResponse.statusCode == 200) {
      final getData = jsonDecode(getResponse.body);
      sha = getData['sha'];
    }

    print('Uploading to: https://api.github.com/repos/$owner/$repo/contents/$path');
    final uri = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');

    final body = {
      'message': 'Upload $type for store $storeId',
      'content': base64Image,
    };
    if (sha != null) {
      body['sha'] = sha;
    }

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('GitHub API response status: ${response.statusCode}');
    print('GitHub API response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final downloadUrl = data['content']['download_url'] as String?;
      if (downloadUrl == null) {
        throw Exception('Download URL not found in response');
      }
      print('$type uploaded to GitHub: $downloadUrl');
      return downloadUrl;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception('GitHub API error: ${errorData['message']} (Status: ${response.statusCode})');
    }
  } catch (e) {
    print('Upload error: $e');
    Get.snackbar('Lỗi', 'Không thể tải ảnh lên GitHub: $e');
    return null;
  }
}


  Future<void> saveStore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Lỗi', 'Người dùng chưa đăng nhập');
      return;
    }
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        categories.isEmpty ||
        provinceController.text.isEmpty ||
        districtController.text.isEmpty ||
        wardController.text.isEmpty ||
        streetController.text.isEmpty ||
        houseNumberController.text.isEmpty ||
        selectedProvinceCode.value == null ||
        selectedDistrictCode.value == null ||
        businessLicenseFile.value == null ||
        foodSafetyCertificateFile.value == null ||
        selectedWardCode.value == null) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin');
      return;
    }
    try {
      isLoading.value = true;
      final storeId = 'store_${user.uid}_${Random().nextInt(10000)}';

      final businessLicenseUrl = await _uploadImageToGitHub(businessLicenseFile.value, storeId, 'business_license');
      final foodSafetyCertificateUrl = await _uploadImageToGitHub(foodSafetyCertificateFile.value, storeId, 'food_safety');

      if (businessLicenseUrl == null || foodSafetyCertificateUrl == null) {
        throw Exception('Failed to upload certificates');
      }

      final store = StoreModel(
        storeId: storeId,
        ownerUid: user.uid,
        name: nameController.text,
        description: descriptionController.text,
        categories: categories.toList(),
        address: '${houseNumberController.text}, ${streetController.text}, ${wardController.text}, ${districtController.text}, ${provinceController.text}',
        businessLicenseUrl: businessLicenseUrl,
        foodSafetyCertificateUrl: foodSafetyCertificateUrl,
        state: 'pending',
      );
      await _firestoreProvider.createStore(store);
      Get.offAllNamed(AppRoutes.sellerHome);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tạo cửa hàng: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    provinceController.dispose();
    districtController.dispose();
    wardController.dispose();
    streetController.dispose();
    houseNumberController.dispose();
    super.onClose();
  }
}