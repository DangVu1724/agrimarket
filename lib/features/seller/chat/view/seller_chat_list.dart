import 'package:agrimarket/core/widgets/chat_screen.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes/app_routes.dart';
import '../viewmodel/seller_chat_vm.dart';

class SellerChatListScreen extends StatelessWidget {
  const SellerChatListScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final SellerHomeVm _vm = Get.find<SellerHomeVm>();
    final SellerChatVM vm = Get.put(SellerChatVM());

    return Scaffold(
      appBar: AppBar(title: Text('Tin nhắn từ người mua')),
      body: Obx(() {
        final store = _vm.store.value;

        if (_vm.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (_vm.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(_vm.errorMessage.value, textAlign: TextAlign.center),
                SizedBox(height: 16),
                ElevatedButton(onPressed: () => _vm.refresh(), child: Text('Thử lại')),
              ],
            ),
          );
        }

        if (store == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("Không tìm thấy thông tin cửa hàng"),
                SizedBox(height: 16),
                ElevatedButton(onPressed: () => _vm.refresh(), child: Text('Tải lại')),
              ],
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: vm.getChatList(store.storeId),
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
                    ElevatedButton(onPressed: () => _vm.refresh(), child: Text('Thử lại')),
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
                    SizedBox(height: 8),
                    Text("Cửa hàng: ${store.name}", style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                final buyerId = members.firstWhere((id) => id != store.storeId);
                final lastMessage = chat['lastMessage'] ?? '';
                final lastTimestamp = (chat['lastTimestamp'] as Timestamp?)?.toDate();

                return FutureBuilder<Map<String, dynamic>?>(
                  future: vm.getBuyerInfo(buyerId),
                  builder: (context, storeSnapshot) {
                    if (storeSnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        leading: CircleAvatar(child: Icon(Icons.store)),
                        title: Text("Đang tải..."),
                        subtitle: Text(lastMessage),
                      );
                    }
                    final buyerData = storeSnapshot.data;
                    final buyerName = buyerData?['name'] ?? 'Không rõ';
                    final buyerImage = buyerData?['photoURL'];

                    return ListTile(
                      leading:
                          buyerImage != null && buyerImage.isNotEmpty
                              ? CircleAvatar(backgroundImage: NetworkImage(buyerImage))
                              : CircleAvatar(child: Icon(Icons.person)),
                      title: Text("$buyerName"),
                      subtitle: Text(lastMessage),
                      trailing:
                          lastTimestamp != null
                              ? Text(_formatTime(lastTimestamp), style: TextStyle(fontSize: 12, color: Colors.grey))
                              : null,
                      onTap: () {
                        Get.to(
                          () => ChatScreen(),
                          arguments: {
                            'currentUserId': store.storeId,
                            'peerId': buyerId,
                            'peerName': buyerName,
                            'peerImage': buyerImage,
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
