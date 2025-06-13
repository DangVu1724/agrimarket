import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CustomAppBar extends StatelessWidget {
  final String pageName;
  final Widget? child;
  final bool backArrow;
  const CustomAppBar({
    super.key,
    this.pageName = "",
    this.child,
    this.backArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BottomWaveClipper(),
      child: Container(
        height: 250,
        width: MediaQuery.sizeOf(context).width,
        color: Colors.teal,
        child: Container(
          margin: EdgeInsets.only(left: 30, top: 70),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            backArrow?
            Container(margin: EdgeInsets.only(top: 10, right: 10), child:  GestureDetector(onTap: () => Get.back(), child: Icon(Iconsax.arrow_square_left_copy, color: Colors.white,),)): SizedBox(), child?? Text(
            pageName,
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          ],
          )
        )
      ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40); // đến gần đáy

    // Tạo vòng cung cong ở đáy
    path.quadraticBezierTo(
      size.width /40,
      size.height -100,
      size.width /6,
      size.height -100
    );
    path.quadraticBezierTo(
      size.width /4,
      size.height -100,
      size.width /2,
      size.height -100
    );
    path.quadraticBezierTo(
      size.width/1.5,
      size.height -100,
      size.width/1.2,
      size.height -100
    );
    path.quadraticBezierTo(
      size.width /1.0005,
      size.height -100,
      size.width,
      size.height -30
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
    



