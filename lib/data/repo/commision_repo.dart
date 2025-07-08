import 'package:agrimarket/data/models/commission.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommissionRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createCommission(CommissionModel commission) async {
    await _firestore.collection('commissions').doc(commission.commissionId).set(commission.toJson());
  }

  Future<void> updateCommissionStatus(String commissionId, String status) async {
    await _firestore.collection('commissions').doc(commissionId).update({'status': status});
  }

  Future<void> deleteCommission(String commissionId) async {
    await _firestore.collection('commissions').doc(commissionId).delete();
  }

  Future<List<CommissionModel>> getCommissionsByStoreId(String storeId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('commissions')
              .where('storeId', isEqualTo: storeId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CommissionModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get commissions by store ID: $e');
    }
  }

  Future<List<CommissionModel>> getCommissionsByStatus(String storeId, String status) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('commissions')
              .where('storeId', isEqualTo: storeId)
              .where('status', isEqualTo: status)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CommissionModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get commissions by status: $e');
    }
  }
}
