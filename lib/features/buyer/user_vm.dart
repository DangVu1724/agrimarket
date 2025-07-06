import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/data/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UserVm extends GetxController {
  final UserService _userService = UserService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final userName = RxString('');
  final userEmail = RxString('');
  final userPhone = RxString('');
  final userAvatar = RxString('');
  final isLoading = false.obs;
  final GlobalKey<FormState> userformKey = GlobalKey<FormState>();

  // Controllers for updating profile
  // final TextEditingController nameController = TextEditingController();
  // final TextEditingController phoneController = TextEditingController();
  // final TextEditingController currentPasswordController = TextEditingController();
  // final TextEditingController newPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      final user = _userService.currentUser;
      if (user != null) {
        final userData = await _userService.getUserData();
        if (userData != null) {
          userName.value = userData.name;
          userEmail.value = user.email ?? '';
          userPhone.value = userData.phone;
          userAvatar.value = user.photoURL ?? 'assets/images/avatar.png';
        } else {
          Get.snackbar('Error', 'User data not found');
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required String newName,
    required String newPhone,
  }) async {
    isLoading.value = true;
    try {
      await _userService.updateProfile(newName: newName, newPhone: newPhone);
      userName.value = newName;
      userPhone.value = newPhone;
      Get.snackbar('Success', 'Profile updated');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _userService.signOut();
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      Get.snackbar('Error', 'Sign out failed');
    }
  }
}
