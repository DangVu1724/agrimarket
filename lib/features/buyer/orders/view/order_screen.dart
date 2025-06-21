import 'package:agrimarket/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(pageName: 'Đơn hàng'),
          Container(
            height: 100,
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: const Color.fromARGB(255, 215, 229, 226),
            ),

            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
              margin: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconWithDescription(
                    text: 'Thanh toán',
                    myIcon: Iconsax.card_pos,
                  ),
                  IconWithDescription(
                    text: 'Đang giao',
                    myIcon: Iconsax.truck_fast,
                  ),
                  IconWithDescription(
                    text: 'Đã nhận',
                    myIcon: Iconsax.gift,
                  ),
                  IconWithDescription(
                    text: 'Đánh giá',
                    myIcon: Iconsax.star_copy,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IconWithDescription extends StatelessWidget {
  final String? text;
  final IconData myIcon;
  final MaterialColor color;
  const IconWithDescription({
    super.key,
    this.text,
    required this.myIcon,
    this.color = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(myIcon, color: color), Text(text ?? "")],
    );
  }
}
