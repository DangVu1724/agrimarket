import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/data/providers/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserVm extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirestoreProvider firestore = FirestoreProvider();
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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await firestore.getUserById(user.uid);

      if (userData != null) {
        userName.value = userData.name;
        userEmail.value = userData.email;
        userPhone.value = userData.phone;
        String avatarUrl = user.photoURL ?? '';
        if (avatarUrl.isEmpty) {
          avatarUrl = 'assets/images/avatar.png';
        }
        userAvatar.value = avatarUrl;
      } else {
        Get.snackbar('Error', 'User data not found');
      }
    }
  }

  Future<void> updateProfile({
    required String newName,
    required String newPhone,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Cập nhật displayName
      await user.updateDisplayName(newName);

      // Cập nhật Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'name': newName, 'phone': newPhone},
      );

    

      Get.snackbar('Thành công', 'Thông tin đã được cập nhật');
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
      final google = GoogleSignIn();
      if (await google.isSignedIn()) {
        await google.disconnect();
        await google.signOut();
      }
      Get.toNamed(AppRoutes.dashboard);
    } catch (e) {
      Get.snackbar('Error', 'Sign out failed');
    }
  }

}
