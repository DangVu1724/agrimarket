import 'package:agrimarket/data/models/commission.dart';
import 'package:agrimarket/data/repo/commision_repo.dart';

class CommissionService {
  final CommissionRepo _commissionRepo = CommissionRepo();

  Future<void> createCommission(CommissionModel commission) async {
    await _commissionRepo.createCommission(commission);
  }

  Future<void> updateCommissionStatus(String commissionId, String status) async {
    await _commissionRepo.updateCommissionStatus(commissionId, status);
  }

  Future<List<CommissionModel>> getCommissionsByStoreId(String storeId) async {
    return await _commissionRepo.getCommissionsByStoreId(storeId);
  }

  Future<List<CommissionModel>> getCommissionsByStatus(String storeId, String status) async {
    return await _commissionRepo.getCommissionsByStatus(storeId, status);
  }
}
