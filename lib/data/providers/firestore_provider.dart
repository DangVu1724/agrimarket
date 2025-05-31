import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrimarket/data/models/user.dart';
import 'package:agrimarket/data/models/buyer.dart'; // Thêm import BuyerModel
import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/models/order.dart';
import 'package:agrimarket/data/models/product.dart';

class FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lưu thông tin người dùng
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
    } catch (e) {
      throw Exception('Lỗi khi lưu thông tin người dùng: $e');
    }
  }

  // Lấy thông tin người dùng theo UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin người dùng: $e');
    }
  }

  // Lưu thông tin BuyerModel
  Future<void> createBuyer(BuyerModel buyer) async {
    try {
      await _firestore.collection('buyers').doc(buyer.uid).set(buyer.toJson());
    } catch (e) {
      throw Exception('Lỗi khi lưu thông tin buyer: $e');
    }
  }

  // Lấy thông tin BuyerModel theo UID
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

  Future<List<StoreModel>> getStoresByOwner(String ownerUid) async {
    try {
      final querySnapshot = await _firestore
          .collection('stores')
          .where('ownerUid', isEqualTo: ownerUid)
          .get();
      return querySnapshot.docs
          .map((doc) => StoreModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting stores: $e');
      rethrow;
    }
  }

  // Lưu thông tin cửa hàng
  Future<void> createStore(StoreModel store) async {
    try {
      await _firestore.collection('stores').doc(store.storeId).set(store.toJson());
    } catch (e) {
      throw Exception('Lỗi khi lưu thông tin cửa hàng: $e');
    }
  }

  // Lưu thông tin đơn hàng
  Future<void> createOrder(OrderModel order) async {
    try {
      await _firestore.collection('orders').doc(order.orderId).set({
        'orderId': order.orderId,
        'buyerUid': order.buyerUid,
        'storeId': order.storeId,
        'items': order.items
            .map((item) => {
                  'productId': item.productId,
                  'name': item.name,
                  'quantity': item.quantity,
                  'price': item.price,
                  'unit': item.unit,
                })
            .toList(),
        'status': order.status,
        'totalPrice': order.totalPrice,
        'createdAt': order.createdAt,
        'deliveryAddress': order.deliveryAddress,
      });
    } catch (e) {
      throw Exception('Lỗi khi lưu đơn hàng: $e');
    }
  }

  // Lưu thông tin sản phẩm
  Future<void> createProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').doc(product.id).set({
        'id': product.id,
        'storeId': product.storeId,
        'name': product.name,
        'category': product.category,
        'description': product.description,
        'price': product.price,
        'unit': product.unit,
        'imageUrl': product.imageUrl,
      });
    } catch (e) {
      throw Exception('Lỗi khi lưu sản phẩm: $e');
    }
  }
}