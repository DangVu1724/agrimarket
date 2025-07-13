import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:agrimarket/core/utils/security_utils.dart';
import 'package:agrimarket/core/constants/env_config.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage({bool fromCamera = false}) async {
    try {
      return await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn ảnh: $e');
      return null;
    }
  }

  Future<String?> uploadImageToGitHub(
    XFile? file, String storeId, String type, String folder) async {
  if (file == null) return null;
  try {
    // Validate file
    if (!SecurityUtils.isValidImageFile(file.name)) {
      throw Exception('Loại file không được hỗ trợ');
    }
    
    final bytes = await file.readAsBytes();
    if (!SecurityUtils.isValidFileSize(bytes.length)) {
      throw Exception('Kích thước file quá lớn (tối đa 5MB)');
    }
    
    final base64Image = base64Encode(bytes);
    final fileName = '$storeId-$type.jpg';
    final path = '$storeId/$folder/$fileName';

    // Use EnvConfig instead of direct dotenv access
    final token = EnvConfig.githubToken;
    final owner = EnvConfig.githubOwner;
    final repo = EnvConfig.githubRepo;

    if (token.isEmpty || owner.isEmpty || repo.isEmpty) {
      throw Exception('Thiếu cấu hình GitHub');
    }

    final getUri =
        Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');
    String? sha;

    // Check if the file already exists
    final getResponse = await http.get(
      getUri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );


    if (getResponse.statusCode == 200) {
      final existingContent = jsonDecode(getResponse.body);
      sha = existingContent['sha'];
      final existingBase64 = existingContent['content'].toString().replaceAll('\n', '').trim();
      
      // If the image is identical, return the existing URL
      if (existingBase64 == base64Image) {
        return existingContent['download_url'];
      }
    } else if (getResponse.statusCode != 404) {
      throw Exception('Lỗi kiểm tra file trên GitHub: ${getResponse.body}');
    }

    // Upload or update the image
    final uri =
        Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');
    final body = {
      'message': 'Upload $type for store $storeId',
      'content': base64Image,
      if (sha != null) 'sha': sha,
    };

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['content']['download_url'] as String?;
    }
    throw Exception('Lỗi tải lên GitHub: ${response.body}');
  } catch (e) {
    Get.snackbar('Lỗi', 'Không thể tải ảnh lên GitHub: $e');
    return null;
  }
}

}