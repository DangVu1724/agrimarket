import 'package:agrimarket/data/providers/firestore_provider.dart';
import 'package:agrimarket/data/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/models/user.dart';
import '../../data/models/buyer.dart';
import '../../data/models/store.dart';
import '../routes/app_routes.dart';
import 'dart:math';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirestoreProvider _firestoreProvider = FirestoreProvider();
  final box = GetStorage();

  var isLoading = false.obs;

  Future<void> signIn({required String email, required String password}) async {
    try {
      isLoading.value = true;

      // 1. Đăng nhập với Firebase Auth
      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        // 2. Kiểm tra email đã xác minh chưa
        final isEmailVerified = await _authService.isEmailVerified();

        if (!isEmailVerified) {
          // Chuyển đến màn hình xác minh email
          Get.offAllNamed(AppRoutes.emailVerify);
          Get.snackbar(
            'Xác minh email',
            'Vui lòng xác minh email trước khi tiếp tục.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // 3. Lấy thông tin người dùng từ Firestore
        final userModel = await _firestoreProvider.getUserById(user.uid);

        if (userModel == null) {
          throw Exception('Không tìm thấy thông tin người dùng');
        }

        // 4. Điều hướng dựa trên vai trò
        if (userModel.role == null) {
          Get.offAllNamed(AppRoutes.roleSelection);
        } else {
          Get.offAllNamed(
            userModel.role == 'buyer'
                ? AppRoutes.buyerHome
                : AppRoutes.sellerHome,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Không tìm thấy tài khoản với email này';
          break;
        case 'wrong-password':
          errorMessage = 'Mật khẩu không đúng';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ';
          break;
        case 'user-disabled':
          errorMessage = 'Tài khoản đã bị vô hiệu hóa';
          break;
        default:
          errorMessage = 'Đã có lỗi xảy ra: ${e.message ?? e.toString()}';
      }
      Get.snackbar('Lỗi', errorMessage);
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã có lỗi không xác định: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Đăng ký và lưu thông tin người dùng
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      isLoading.value = true;

      // 1. Đăng ký tài khoản Firebase Auth
      final user = await _authService.registerWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        // 2. Gửi email xác minh
        await _authService.sendEmailVerification(user);

        // 3. Lưu thông tin người dùng vào GetStorage
        box.write('pendingUser', {
          'email': email,
          'name': name,
          'phone': phone,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
        });

        // 4. Chuyển sang màn chọn vai trò
        Get.offAllNamed(AppRoutes.emailVerify);
      }
    } catch (e) {
      Get.snackbar("Lỗi", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Xác minh email trước khi tiếp tục
  Future<void> checkEmailVerificationAndProceed() async {
    final verified = await _authService.isEmailVerified();
    if (verified) {
      Get.offAllNamed(AppRoutes.roleSelection);
    } else {
      Get.snackbar(
        "Xác minh email",
        "Vui lòng xác minh email trước khi tiếp tục.",
      );
    }
  }


  Future<void> updateUserRole(
    String role, {
    String? storeName,
    String? storeAddress,
    List<String>? categories,
    String? addressLabel,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Đọc dữ liệu tạm thời đã lưu từ GetStorage
      final pendingUser = box.read('pendingUser');
      if (pendingUser == null) {
        throw Exception('Không tìm thấy thông tin người dùng tạm thời');
      }

      // Tạo UserModel
      final newUser = UserModel(
        uid: user.uid,
        email: pendingUser['email'],
        name: pendingUser['name'],
        phone: pendingUser['phone'],
        role: role,
        createdAt: DateTime.now()
      );

      // Lưu UserModel vào Firestore
      await _firestoreProvider.createUser(newUser);

      if (role == 'buyer') {
        final List<Address> addresses = [];
        if (address != null && addressLabel != null) {
          addresses.add(
            Address(
              label: addressLabel,
              address: address,
              latitude: latitude ?? pendingUser['latitude'],
              longitude: longitude ?? pendingUser['longitude'],
            ),
          );
        }

        final buyer = BuyerModel(
          uid: user.uid,
          favoriteStoreIds: [],
          addresses: addresses,
          reviews: [],
          orderIds: [],
        );

        await _firestoreProvider.createBuyer(buyer);
      } else if (role == 'seller') {
        Get.offAllNamed(AppRoutes.createStoreInfo);
      } else {
        throw Exception('Vai trò không hợp lệ');
      }
      box.remove('pendingUser');

      Get.offAllNamed(
        role == 'buyer' ? AppRoutes.buyerHome : AppRoutes.sellerHome,
      );
    } catch (e) {
      Get.snackbar("Lỗi", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final user = await _authService.signInWithGoogle();

      if (user != null) {
        // Lấy dữ liệu user từ Firestore
        final userModel = await _firestoreProvider.getUserById(user.uid);

        if (userModel == null) {
          // Nếu lần đầu đăng nhập bằng Google, tạo tài khoản mặc định
          box.write('pendingUser', {
            'email': user.email ?? '',
            'name': user.displayName ?? '',
            'phone': user.phoneNumber ?? '',
            'role': null,
          });

          // Chuyển sang chọn role
          Get.offAllNamed(AppRoutes.roleSelection);
        } else {
          // Nếu đã có tài khoản, chuyển trang theo role
          if (userModel.role == null) {
            Get.offAllNamed(AppRoutes.roleSelection);
          } else {
            Get.offAllNamed(
              userModel.role == 'buyer'
                  ? AppRoutes.buyerHome
                  : AppRoutes.sellerHome,
            );
          }
        }
      }
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
      print('Error signing in with Google: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
