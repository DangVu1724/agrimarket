import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ChatVm extends GetxController {
  final String currentUserId; // ID của người dùng hiện tại (buyer/seller)
  final String peerId; // ID của người chat cùng (seller/buyer)
  final RxBool isShow = true.obs;

  final messages = <Map<String, dynamic>>[].obs;

  late final String chatId;
  late final CollectionReference chatRef;

  ChatVm({required this.currentUserId, required this.peerId}) {
    chatId = _generateChatId(currentUserId, peerId);
    chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages');

    _listenMessages();
  }

  void closeNotice() {
    isShow.value = false;
  }

  String _generateChatId(String a, String b) {
    final ids = [a, b]..sort(); 
    return '${ids[0]}_${ids[1]}'; 
  }

  void _listenMessages() {
    chatRef.orderBy('timestamp').snapshots().listen((snapshot) {
      messages.value = snapshot.docs.map((e) => e.data() as Map<String, dynamic>).toList();
    });
  }

  Future<void> sendMessage(String text) async {
    final message = {'senderId': currentUserId, 'text': text, 'timestamp': Timestamp.now(), 'type': 'text'};

    await chatRef.add(message);

    // Lưu thông tin chat tổng quát (có thể dùng để load danh sách chat)
    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'members': [currentUserId, peerId],
      'lastMessage': text,
      'lastTimestamp': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getStoreInfo(String storeId) async {
    final doc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }
}

