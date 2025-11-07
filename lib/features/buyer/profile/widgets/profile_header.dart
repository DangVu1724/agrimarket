import 'package:agrimarket/features/buyer/user_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../buyer_vm .dart';
import 'rank_card.dart';

class ProfileHeader extends StatelessWidget {
  final UserVm vm;
  final BuyerVm buyerVm;

  const ProfileHeader({
    super.key,
    required this.vm,
    required this.buyerVm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          _buildBackgroundPattern(),
          _buildUserInfo(),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Stack(
      children: [
        Positioned(
          right: -50,
          top: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -30,
          bottom: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildUserAvatar(),
              const SizedBox(width: 16),
              _buildUserDetails(),
            ],
          ),
          const SizedBox(height: 20),
          RankCard(buyerVm: buyerVm),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Obx(() => Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.grey[200],
        backgroundImage: vm.userAvatar.value.isNotEmpty &&
            vm.userAvatar.value.startsWith('http')
            ? NetworkImage(vm.userAvatar.value)
            : const AssetImage('assets/images/avatar.png')
        as ImageProvider,
      ),
    ));
  }

  Widget _buildUserDetails() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
            vm.userName.value.isNotEmpty
                ? vm.userName.value
                : 'Chưa cập nhật tên',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
          const SizedBox(height: 4),
          Obx(() => Text(
            vm.userEmail.value.isNotEmpty
                ? vm.userEmail.value
                : 'Chưa cập nhật email',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          )),
        ],
      ),
    );
  }
}