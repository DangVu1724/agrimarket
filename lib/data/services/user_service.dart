import 'package:agrimarket/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserData() async {
    if (currentUser == null) return null;
    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<void> updateProfile({required String newName, required String newPhone}) async {
    final user = currentUser;
    if (user == null) throw Exception('User not logged in');

    await user.updateDisplayName(newName);
    await _firestore.collection('users').doc(user.uid).update({
      'name': newName,
      'phone': newPhone,
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final google = GoogleSignIn();
    if (await google.isSignedIn()) {
      await google.disconnect();
      await google.signOut();
    }
    await _storage.erase();
  }
}
