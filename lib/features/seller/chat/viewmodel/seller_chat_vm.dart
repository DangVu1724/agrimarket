import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SellerChatVM extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách cuộc chat của store
  Stream<QuerySnapshot> getChatList(String storeId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('members', arrayContains: storeId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatListByBuyerId(String buyerId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('members', arrayContains: buyerId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getBuyerInfo(String buyerId) async {
    // Try to get user info from 'users' collection (for name and photoURL)
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(buyerId).get();
    if (userDoc.exists) {
      final userData = userDoc.data();
      return {'name': userData?['name'] ?? 'Không rõ', 'photoURL': userData?['photoURL']};
    }
    // Fallback: get from 'buyer' collection (legacy, may not have name/image)
    final buyerDoc = await FirebaseFirestore.instance.collection('buyer').doc(buyerId).get();
    if (buyerDoc.exists) {
      final buyerData = buyerDoc.data();
      return {
        'name': buyerData?['name'] ?? 'Không rõ',
        // No image field in buyer, so null
        'photoURL': null,
      };
    }
    return null;
  }
}
