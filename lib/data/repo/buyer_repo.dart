import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrimarket/data/models/buyer.dart';

class BuyerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBuyer(BuyerModel buyer) async {
    try {
      await _firestore.collection('buyers').doc(buyer.uid).set(buyer.toJson());
    } catch (e) {
      throw Exception('Lỗi khi lưu thông tin buyer: $e');
    }
  }

  Future<BuyerModel?> getBuyerById(String uid) async {
    try {
      final doc = await _firestore.collection('buyers').doc(uid).get();
      if (doc.exists) {
        return BuyerModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin buyer: $e');
    }
  }

  Future<void> updateBuyer(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('buyers').doc(uid).update(data);
  }
}
