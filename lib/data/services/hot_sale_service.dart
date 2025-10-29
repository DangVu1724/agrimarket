import 'package:agrimarket/data/models/promotion_campaign.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotSaleService {
  final _firestore = FirebaseFirestore.instance;

  Stream<PromotionCampaignModel?> getCurrentHotSaleStream() {
    return _firestore
        .collection('promotions')
        .where('type', isEqualTo: 'hot_sale')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return PromotionCampaignModel.fromJson(snapshot.docs.first.data());
    });
  }

  Stream<List<Map<String, dynamic>>> getStoresByIds(List<String> ids) {
    if (ids.isEmpty) return const Stream.empty();
    return _firestore
        .collection('stores')
        .where(FieldPath.documentId, whereIn: ids)
        .snapshots()
        .map((s) => s.docs.map((e) => e.data()).toList());
  }
}
