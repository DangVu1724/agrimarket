// class BuyerHomeViewModel extends GetxController {
//   final FirestoreProvider firestore = FirestoreProvider();
//   final FirebaseAuth auth = FirebaseAuth.instance;

//   var isLoading = false.obs;
//   var userName = ''.obs;
//   var userEmail = ''.obs;
//   var userPhone = ''.obs;
//   var userAvatar = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadUserData();
//   }

//   Future<void> loadUserData() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final userData = await firestore.getUserById(user.uid);

//       if (userData != null) {
//         userName.value = userData.name;
//         userEmail.value = userData.email;
//         userPhone.value = userData.phone;
//         String avatarUrl = userData.photoURL ?? '';
//         if (avatarUrl.isEmpty) {
//           avatarUrl = 'assets/images/avatar.png';
//         }
//         userAvatar.value = avatarUrl;
//       } else {
//         Get.snackbar('Error', 'User data not found');
//       }
//     }
//   }
// }