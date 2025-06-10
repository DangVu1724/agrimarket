import 'package:agrimarket/data/models/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuRepository {
  final CollectionReference _menusCollection = FirebaseFirestore.instance.collection('menus');

  Future<MenuModel?> fetchMenu(String storeId) async {
    try {
      final docSnapshot = await _menusCollection.doc(storeId).get();
      if (docSnapshot.exists) {
        return MenuModel.fromJson(docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Không thể tải menu: $e');
    }
  }

  Future<void> saveMenu(MenuModel menu) async {
    try {
      await _menusCollection.doc(menu.storeId).set(menu.toJson());
    } catch (e) {
      throw Exception('Không thể lưu menu: $e');
    }
  }
}