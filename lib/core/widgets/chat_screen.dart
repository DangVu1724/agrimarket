import 'package:agrimarket/features/buyer/chat/viewmodel/chat_vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatelessWidget {
  final String currentUserId = Get.arguments['currentUserId'];
  final String peerId = Get.arguments['peerId'];
  final String peerName = Get.arguments['peerName'];
  final String? peerImage = Get.arguments['peerImage'];

  final TextEditingController messageController = TextEditingController();

  late final ChatVm vm = Get.put(ChatVm(currentUserId: currentUserId, peerId: peerId), tag: '${currentUserId}_$peerId');

  ChatScreen({super.key});

  Widget _buildDateLabel(DateTime time) {
    final formatted = DateFormat("dd MMM, yyyy", "vi").format(time);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
          child: Text(formatted, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg, bool isMe, {bool isFirstOfDay = false}) {
    DateTime? ts;
    if (msg['timestamp'] is Timestamp) {
      ts = (msg['timestamp'] as Timestamp).toDate();
    } else if (msg['timestamp'] is DateTime) {
      ts = msg['timestamp'];
    }
    final timeStr = ts != null ? DateFormat('HH:mm').format(ts) : '';

    return Column(
      children: [
        if (isFirstOfDay && ts != null) _buildDateLabel(ts),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(left: isMe ? 54 : 12, right: isMe ? 12 : 54, top: 2, bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFE1F8F7) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              border: Border.all(color: isMe ? const Color(0xFFB8E8E3) : Colors.grey[200]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(msg['text'] ?? '', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(timeStr, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all, size: 16, color: Color(0xFF40C0A7)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String peerImage = Get.arguments['peerImage'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  (peerImage.trim().isNotEmpty)
                      ? NetworkImage(peerImage!)
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
            ),

            const SizedBox(width: 10),
            Text(peerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
          ],
        ),
        actions: const [Icon(Icons.more_vert, color: Colors.blueAccent), SizedBox(width: 8)],
      ),
      body: Column(
        children: [
          Obx(
            () => vm.isShow == true ? _buildNoticeBox() : SizedBox.shrink(),
          ),
          Expanded(
            child: Obx(() {
              final messages = vm.messages;
              List<Widget> messageWidgets = [];
              DateTime? lastDate;
              for (int i = 0; i < messages.length; i++) {
                final msg = messages[i];
                DateTime? curDate;
                if (msg['timestamp'] is Timestamp) {
                  curDate = (msg['timestamp'] as Timestamp).toDate();
                } else if (msg['timestamp'] is DateTime) {
                  curDate = msg['timestamp'];
                }
                bool isFirstOfDay = false;
                if (curDate != null) {
                  if (lastDate == null || !DateUtils.isSameDay(curDate, lastDate)) {
                    isFirstOfDay = true;
                    lastDate = curDate;
                  }
                }
                bool isMe = msg['senderId'] == currentUserId;
                messageWidgets.add(_buildMessage(msg, isMe, isFirstOfDay: isFirstOfDay));
              }
              return ListView(padding: const EdgeInsets.only(bottom: 12), children: messageWidgets, reverse: false);
            }),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)),
                      child: TextField(
                        controller: messageController,
                        decoration: const InputDecoration(hintText: 'Soạn tin...', border: InputBorder.none),
                        minLines: 1,
                        maxLines: 4,
                        onSubmitted: (_) {
                          if (messageController.text.trim().isNotEmpty) {
                            vm.sendMessage(messageController.text.trim());
                            messageController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.insert_emoticon, color: Colors.blueAccent), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: () {
                      if (messageController.text.trim().isNotEmpty) {
                        vm.sendMessage(messageController.text.trim());
                        messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeBox() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF9E6),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 20),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'LƯU Ý: Agrimarket KHÔNG cho phép hành vi: Đặt cọc/Chuyển khoản riêng/Giao dịch ngoài nền tảng/Tuyển CTV/Tặng quà miễn phí/Cung cấp thông tin liên hệ hoặc Hủy đơn theo yêu cầu người Bán, ...',
                style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w400),
              ),
            ),
            GestureDetector(
              onTap: () {
                vm.isShow.value = false; 
              },
              child: const Icon(Icons.close, size: 20, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Vui lòng chỉ Mua-Bán trực tiếp trên Agrimarket để tránh bị lừa đảo. Agrimarket sẽ thu thập và sử dụng lịch sử chat theo Chính sách bảo mật của Agrimarket.',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Tìm hiểu thêm ', style: TextStyle(fontSize: 14)),
            GestureDetector(
              onTap: () {},
              child: const Text('Tố cáo người dùng này!', style: TextStyle(fontSize: 14, color: Colors.blue)),
            ),
          ],
        ),
      ],
    ),
  );
}

}
