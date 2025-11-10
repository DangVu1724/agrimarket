import 'package:agrimarket/core/widgets/chat_screen.dart';
import 'package:agrimarket/features/seller/chat/viewmodel/seller_chat_vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../buyer_vm .dart';

class BuyerChatListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SellerChatVM vm = Get.put(SellerChatVM());
  final BuyerVm buyerVm = Get.find<BuyerVm>();

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat.Hm('vi_VN').format(time);
    } else if (messageDate == yesterday) {
      return 'Hôm qua';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tin nhắn',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        final buyer = buyerVm.buyerData.value;

        if (buyerVm.isLoading.value) {
          return _buildLoadingState();
        }

        if (buyer == null) {
          return _buildEmptyState(
            icon: Icons.person_outline_rounded,
            title: 'Không tìm thấy thông tin',
            subtitle: 'Vui lòng kiểm tra lại thông tin người dùng',
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: vm.getChatList(buyer.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return _buildEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Lỗi kết nối',
                subtitle: 'Không thể tải danh sách tin nhắn',
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Chưa có tin nhắn',
                subtitle: 'Hãy bắt đầu trò chuyện với cửa hàng',
              );
            }

            final chats = snapshot.data!.docs;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: chats.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
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
                    final storeData = storeSnapshot.data;
                    final storeName = storeData?['name'] ?? 'Cửa hàng';
                    final storeImage = storeData?['storeImageUrl'];
                    final isOnline = storeData?['isOnline'] ?? false;

                    return _buildChatItem(
                      storeName: storeName,
                      storeImage: storeImage,
                      lastMessage: lastMessage,
                      lastTimestamp: lastTimestamp,
                      isOnline: isOnline,
                      onTap: () {
                        Get.to(
                              () => ChatScreen(),
                          arguments: {
                            'currentUserId': buyer.uid,
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

  Widget _buildChatItem({
    required String storeName,
    required String? storeImage,
    required String lastMessage,
    required DateTime? lastTimestamp,
    required bool isOnline,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar với online status
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: storeImage != null && storeImage.isNotEmpty
                          ? Image.network(
                        storeImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderAvatar(storeName),
                      )
                          : _buildPlaceholderAvatar(storeName),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Thông tin chat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            storeName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastTimestamp != null)
                          Text(
                            _formatTime(lastTimestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage.isNotEmpty ? lastMessage : 'Chưa có tin nhắn',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar(String storeName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          storeName.isNotEmpty ? storeName[0].toUpperCase() : 'C',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Skeleton avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              // Skeleton text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity * 0.7,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}