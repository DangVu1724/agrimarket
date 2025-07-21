import 'package:agrimarket/core/widgets/chat_screen.dart';
import 'package:agrimarket/features/buyer/buyer_vm%20.dart';
import 'package:agrimarket/features/seller/chat/viewmodel/seller_chat_vm.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BuyerChatListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat.Hm('vi_VN').format(time);
    } else if (messageDate == yesterday) {
      return 'Hôm qua ${DateFormat.Hm('vi_VN').format(time)}';
    } else if (now.difference(time).inDays < 7) {
      return DateFormat.E('vi_VN').format(time);
    } else {
      return DateFormat.yMd('vi_VN').format(time);
    }
  }

  Future<Map<String, dynamic>?> getStoreInfo(String storeId) async {
    final doc = await _firestore.collection('stores').doc(storeId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final SellerChatVM vm = Get.put(SellerChatVM());
    final BuyerVm buyerVm = Get.find<BuyerVm>();

    return Scaffold(
      appBar: AppBar(title: Text('Tin nhắn')),
      body: Obx(() {
        final buyer = buyerVm.buyerData.value;

        if (buyerVm.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (buyer == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("Không tìm thấy thông tin người dùng"),
                SizedBox(height: 16),
              ],
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: vm.getChatList(buyer.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text("Lỗi khi tải tin nhắn: ${snapshot.error}"),
                    SizedBox(height: 16),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("Chưa có tin nhắn nào.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              );
            }

            final chats = snapshot.data!.docs;

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final chatId = chat.id;
                final members = List<String>.from(chat['members']);
                final storeId = members.firstWhere((id) => id != buyer.uid);
                final lastMessage = chat['lastMessage'] ?? '';
                final lastTimestamp = (chat['lastTimestamp'] as Timestamp?)?.toDate();

                return FutureBuilder<Map<String, dynamic>?>(
                  future: getStoreInfo(storeId),
                  builder: (context, storeSnapshot) {
                    if (storeSnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        leading: CircleAvatar(child: Icon(Icons.store)),
                        title: Text("Đang tải..."),
                        subtitle: Text(lastMessage),
                      );
                    }
                    final storeData = storeSnapshot.data;
                    final storeName = storeData?['name'] ?? 'Không rõ';
                    final storeImage = storeData?['storeImageUrl'];

                    return ListTile(
                      leading:
                          storeImage != null
                              ? CircleAvatar(backgroundImage: NetworkImage(storeImage))
                              : CircleAvatar(child: Icon(Icons.store)),
                      title: Text("Cửa hàng: $storeName"),
                      subtitle: Text(lastMessage),
                      trailing:
                          lastTimestamp != null
                              ? Text(_formatTime(lastTimestamp), style: TextStyle(fontSize: 12, color: Colors.grey))
                              : null,
                      onTap: () {
                        Get.to(
                          () => ChatScreen(),
                          arguments: {
                            'currentUserId': buyerVm.buyerData.value?.uid,
                            'peerId': storeId,
                            'peerName': storeName,
                            'peerImage': storeImage,
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      }),
    );
  }
}
