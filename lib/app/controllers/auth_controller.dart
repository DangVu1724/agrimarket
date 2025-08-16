import 'package:agrimarket/data/repo/buyer_repo.dart';
import 'package:agrimarket/data/repo/store_repo.dart';
import 'package:agrimarket/data/repo/user_repo.dart';
import 'package:agrimarket/data/services/auth_service.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import '../../data/models/user.dart';
import '../../data/models/buyer.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();
  final BuyerRepository _buyerRepository = BuyerRepository();
  final StoreRepository _storeRepository = StoreRepository();
  final Box _box = Hive.box('storeCache');

  var isLoading = false.obs;

  Future<void> signIn({required String email, required String password}) async {
    try {
      isLoading.value = true;

      // Clear cache trước khi sign in
      _box.clear();
      await _clearAllHiveCache();

      final user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        final isEmailVerified = await _authService.checkEmailVerified();
        if (!isEmailVerified) {
          throw FirebaseAuthException(
            code: 'email-not-verified',
            message: 'Vui lòng xác minh email trước khi tiếp tục.',
          );
        }

        final userModel = await _userRepository.getUserById(user.uid);

        if (userModel == null) {
          throw Exception('Không tìm thấy thông tin người dùng');
        }

        _box.put('user', {'uid': userModel.uid, 'role': userModel.role});

        // Force refresh seller controllers if user is seller
        if (userModel.role == 'seller') {
          try {
            // Delete and recreate SellerHomeVm to clear old data
            Get.delete<SellerHomeVm>();
            Get.put(SellerHomeVm());
          } catch (e) {
            print('Error refreshing SellerHomeVm: $e');
          }
        }

        await _navigateByRole(user.uid, userModel.role);
      }
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Đã có lỗi không xác định: $e');
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
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkEmailVerificationAndProceed() async {
    final verified = await _authService.checkEmailVerified();
    if (verified) {
      Get.offAllNamed(AppRoutes.roleSelection);
    } else {
      // Không dùng snackbar nữa, trả lỗi về ViewModel nếu cần
      throw FirebaseAuthException(code: 'email-not-verified', message: 'Vui lòng xác minh email trước khi tiếp tục.');
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

      final pendingUser = _box.get('pendingUser');

      if (pendingUser == null) throw Exception('Không tìm thấy thông tin người dùng tạm thời');

      final newUser = UserModel(
        uid: user.uid,
        email: pendingUser['email'],
        name: pendingUser['name'],
        phone: pendingUser['phone'],
        role: role,
        createdAt: DateTime.now(),
      );

      await _userRepository.createUser(newUser);

      if (role == 'buyer') {
        final addresses = <Address>[];
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

        final buyer = BuyerModel(uid: user.uid, favoriteStoreIds: [], addresses: addresses, orderIds: []);
        await _buyerRepository.createBuyer(buyer);
      }

      _box.delete('pendingUser');

      Get.offAllNamed(role == 'buyer' ? AppRoutes.buyerHome : AppRoutes.createStoreInfo);
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      // Clear cache trước khi sign in Google
      _box.clear();
      await _clearAllHiveCache();

      final user = await _authService.signInWithGoogle();
      if (user != null) {
        final userModel = await _userRepository.getUserById(user.uid);

        if (userModel == null) {
          _savePendingUser(user.email ?? '', user.displayName ?? '', user.phoneNumber ?? '', null, null, null);
          Get.offAllNamed(AppRoutes.roleSelection);
        } else {
          await _navigateByRole(user.uid, userModel.role);
        }
      }
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _promptEmailVerification() {
    throw FirebaseAuthException(code: 'email-not-verified', message: 'Vui lòng xác minh email trước khi tiếp tục.');
  }

  Future<void> _navigateByRole(String uid, String? role) async {
    if (role == null) {
      Get.offAllNamed(AppRoutes.roleSelection);
    } else if (role == 'seller') {
      final storedNeedsStoreCreation = _box.get('needsStoreCreation') ?? false;
      final stores = await _storeRepository.getStoresByOwner(uid);

      if (stores.isEmpty || storedNeedsStoreCreation) {
        _box.put('needsStoreCreation', true);
        Get.offAllNamed(AppRoutes.createStoreInfo);
      } else {
        _box.delete('needsStoreCreation');
        Get.offAllNamed(AppRoutes.sellerHome);
      }
    } else {
      Get.offAllNamed(AppRoutes.buyerHome);
    }
  }

  void _savePendingUser(
    String email,
    String name,
    String phone, [
    String? address,
    double? latitude,
    double? longitude,
  ]) {
    _box.put('pendingUser', {
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<void> _clearAllHiveCache() async {
    try {
      final boxes = [
        'userCache',
        'storeCache',
        'productCache',
        'menuCache',
        'promotionCache',
        'discountCodeCache',
        'payment_method',
      ];

      for (final boxName in boxes) {
        try {
          final box = Hive.box(boxName);
          await box.clear();
        } catch (e) {
          // Box might not exist, ignore error
        }
      }
    } catch (e) {
      // Ignore errors when clearing cache
    }
  }
}
