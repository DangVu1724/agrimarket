import 'package:agrimarket/data/providers/firestore_provider.dart';
import 'package:agrimarket/data/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/models/user.dart';
import '../../data/models/buyer.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirestoreProvider _firestoreProvider = FirestoreProvider();
  final box = GetStorage();

  var isLoading = false.obs;

  Future<void> signIn({required String email, required String password}) async {
    try {
      isLoading.value = true;

      final user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        final isEmailVerified = await _authService.checkEmailVerified();
        if (!isEmailVerified) {
          return _promptEmailVerification();
        }

        final userModel = await _firestoreProvider.getUserById(user.uid);
        if (userModel == null) {
          throw Exception('Không tìm thấy thông tin người dùng');
        }

        await _navigateByRole(user.uid, userModel.role);
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã có lỗi không xác định: $e');
    } finally {
      isLoading.value = false;
    }
  }

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

      final user = await _authService.registerWithEmailAndPassword(email, password);
      if (user != null) {
        await _authService.sendEmailVerification();
        _savePendingUser(email, name, phone, address, latitude, longitude);
        Get.offAllNamed(AppRoutes.emailVerify);
      }
    } catch (e) {
      Get.snackbar("Lỗi", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkEmailVerificationAndProceed() async {
    final verified = await _authService.checkEmailVerified();
    if (verified) {
      Get.offAllNamed(AppRoutes.roleSelection);
    } else {
      Get.snackbar("Xác minh email", "Vui lòng xác minh email trước khi tiếp tục.");
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
      if (user == null) throw Exception('Người dùng chưa đăng nhập');

      final pendingUser = box.read('pendingUser');
      if (pendingUser == null) throw Exception('Không tìm thấy thông tin người dùng tạm thời');

      final newUser = UserModel(
        uid: user.uid,
        email: pendingUser['email'],
        name: pendingUser['name'],
        phone: pendingUser['phone'],
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestoreProvider.createUser(newUser);

      if (role == 'buyer') {
        final addresses = <Address>[];
        if (address != null && addressLabel != null) {
          addresses.add(Address(
            label: addressLabel,
            address: address,
            latitude: latitude ?? pendingUser['latitude'],
            longitude: longitude ?? pendingUser['longitude'],
          ));
        }

        final buyer = BuyerModel(
          uid: user.uid,
          favoriteStoreIds: [],
          addresses: addresses,
          reviews: [],
          orderIds: [],
        );
        await _firestoreProvider.createBuyer(buyer);
      }

      box.remove('pendingUser');

      Get.offAllNamed(
        role == 'buyer' ? AppRoutes.buyerHome : AppRoutes.createStoreInfo,
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
        final userModel = await _firestoreProvider.getUserById(user.uid);

        if (userModel == null) {
          _savePendingUser(
            user.email ?? '',
            user.displayName ?? '',
            user.phoneNumber ?? '',
            null,
            null,
            null,
          );
          Get.offAllNamed(AppRoutes.roleSelection);
        } else {
          await _navigateByRole(user.uid, userModel.role);
        }
      }
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
      print('Error signing in with Google: $e');
    } finally {
      isLoading.value = false;
    }
  }


  void _promptEmailVerification() {
    Get.offAllNamed(AppRoutes.emailVerify);
    Get.snackbar(
      'Xác minh email',
      'Vui lòng xác minh email trước khi tiếp tục.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _navigateByRole(String uid, String? role) async {
    if (role == null) {
      Get.offAllNamed(AppRoutes.roleSelection);
    } else if (role == 'seller') {
      final storedNeedsStoreCreation = box.read('needsStoreCreation') ?? false;
      final stores = await _firestoreProvider.getStoresByOwner(uid);

      if (stores.isEmpty || storedNeedsStoreCreation) {
        box.write('needsStoreCreation', true);
        Get.offAllNamed(AppRoutes.createStoreInfo);
      } else {
        box.remove('needsStoreCreation');
        Get.offAllNamed(AppRoutes.sellerHome);
      }
    } else {
      Get.offAllNamed(AppRoutes.buyerHome);
    }
  }

  void _handleFirebaseAuthError(FirebaseAuthException e) {
    final errorMessage = switch (e.code) {
      'user-not-found' => 'Không tìm thấy tài khoản với email này',
      'wrong-password' => 'Mật khẩu không đúng',
      'invalid-email' => 'Email không hợp lệ',
      'user-disabled' => 'Tài khoản đã bị vô hiệu hóa',
      _ => 'Đã có lỗi xảy ra: ${e.message ?? e.toString()}',
    };
    Get.snackbar('Lỗi', errorMessage);
  }

  void _savePendingUser(
    String email,
    String name,
    String phone, [
    String? address,
    double? latitude,
    double? longitude,
  ]) {
    box.write('pendingUser', {
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    });
  }
}

