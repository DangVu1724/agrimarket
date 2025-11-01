import 'package:agrimarket/data/models/commission.dart';
import 'package:agrimarket/data/repo/commision_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommissionService {
  final CommissionRepo _commissionRepo = CommissionRepo();

  Future<void> createCommission(CommissionModel commission) async {
    await _commissionRepo.createCommission(commission);
  }

  Future<void> updateCommissionStatus(String commissionId, String status, DateTime paidDate) async {
    await _commissionRepo.updateCommissionStatus(commissionId, status, paidDate);
  }

  Future<List<CommissionModel>> getCommissionsByStoreId(String storeId) async {
    return await _commissionRepo.getCommissionsByStoreId(storeId);
  }

  Stream<List<CommissionModel>> getCommissionsByStatus(String storeId, String status)  {
    return  _commissionRepo.getCommissionsByStatus(storeId, status);
  }

  Future<List<CommissionModel>> getCommissionsByDateAndStatus(String storeId, String dateKey, String status) async {
    final startOfDay = DateTime.parse('$dateKey 00:00:00');
    final endOfDay = DateTime.parse('$dateKey 23:59:59');

    final snapshot =
        await FirebaseFirestore.instance
            .collection('commissions')
            .where('storeId', isEqualTo: storeId)
            .where('status', isEqualTo: status)
            .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
            .where('createdAt', isLessThanOrEqualTo: endOfDay)
            .get();

    return snapshot.docs.map((doc) => CommissionModel.fromJson({...doc.data(), 'commissionId': doc.id})).toList();
  }

  Future<void> updateCommission(CommissionModel commission) async {
    try {
      await FirebaseFirestore.instance.collection('commissions').doc(commission.commissionId).update(commission.toJson());
    } catch (e) {
      throw Exception('Failed to update commission: $e');
    }
  }
}
