import 'package:agrimarket/data/models/cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToCart(String userId, CartItem item) async {
    try {
      final cartRef = _firestore.collection('carts').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(cartRef);

        if (doc.exists) {
          // Cập nhật giỏ hàng đã tồn tại
          final items = List<Map<String, dynamic>>.from(doc.data()!['items']);
          final existingIndex = items.indexWhere(
            (i) =>
                i['productId'] == item.productId &&
                i['storeId'] == item.storeId,
          );

          if (existingIndex >= 0) {
            // Cập nhật số lượng nếu sản phẩm đã có
            items[existingIndex]['quantity'] += item.quantity;
          } else {
            // Thêm sản phẩm mới
            items.add(item.toJson());
          }

          transaction.update(cartRef, {
            'items': items,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Tạo giỏ hàng mới
          transaction.set(cartRef, {
            'userId': userId,
            'items': [item.toJson()],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('Không thể thêm sản phẩm vào giỏ hàng: $e');
    }
  }

  Future<void> removeItems(String userId, CartItem item) async {
    try {
      final cartRef = _firestore.collection('carts').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(cartRef);

        if (doc.exists) {
          // Cập nhật giỏ hàng đã tồn tại
          final items = List<Map<String, dynamic>>.from(doc.data()!['items']);
          final updateItem =
              items
                  .where(
                    (i) =>
                        !(i['productId'] == item.productId &&
                            i['storeId'] == item.storeId),
                  )
                  .toList();

          transaction.update(cartRef, {
            'items': updateItem,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('Không thể thêm sản phẩm vào giỏ hàng: $e');
    }
  }

  Future<Cart?> getCart(String userId) async {
    try {
      final doc = await _firestore.collection('carts').doc(userId).get();

      if (doc.exists) {
        final data = doc.data()!;
        return Cart(
          userId: userId,
          items:
              (data['items'] as List)
                  .map((item) => CartItem.fromJson(item))
                  .toList(),
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt:
              data['updatedAt'] != null
                  ? (data['updatedAt'] as Timestamp).toDate()
                  : null,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Không thể lấy giỏ hàng: $e');
    }
  }

  Future<void> updateCartItemQuantity({
    required String userId,
    required String productId,
    required String storeId,
    required int newQuantity,
  }) async {
    try {
      final cartRef = _firestore.collection('carts').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(cartRef);

        if (doc.exists) {
          final items = List<Map<String, dynamic>>.from(doc.data()!['items']);
          final index = items.indexWhere(
            (i) => i['productId'] == productId && i['storeId'] == storeId,
          );

          if (index >= 0) {
            if (newQuantity > 0) {
              items[index]['quantity'] = newQuantity;
            } else {
              items.removeAt(index);
            }

            transaction.update(cartRef, {
              'items': items,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      });
    } catch (e) {
      throw Exception('Không thể cập nhật giỏ hàng: $e');
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      await _firestore.collection('carts').doc(userId).delete();
    } catch (e) {
      throw Exception('Không thể xóa giỏ hàng: $e');
    }
  }
}
