import 'package:flutter/material.dart';

class PromotionBadge extends StatelessWidget {
  final bool isPromotion;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const PromotionBadge({super.key, required this.isPromotion, this.size = 20, this.backgroundColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    if (!isPromotion) {
      return const SizedBox.shrink();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Center(child: Icon(Icons.local_offer, size: size * 0.6, color: textColor ?? Colors.white)),
    );
  }
}

class PromotionBadgeWithText extends StatelessWidget {
  final bool isPromotion;
  final String text;
  final double fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets padding;

  const PromotionBadgeWithText({
    super.key,
    required this.isPromotion,
    this.text = 'KM',
    this.fontSize = 12,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    if (!isPromotion) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_offer, size: fontSize, color: textColor ?? Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: textColor ?? Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class PromotionBadgeOverlay extends StatelessWidget {
  final bool isPromotion;
  final Widget child;
  final Alignment alignment;
  final double size;

  const PromotionBadgeOverlay({
    super.key,
    required this.isPromotion,
    required this.child,
    this.alignment = Alignment.topRight,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPromotion) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          top: alignment == Alignment.topRight || alignment == Alignment.topLeft ? 8 : null,
          bottom: alignment == Alignment.bottomRight || alignment == Alignment.bottomLeft ? 8 : null,
          left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft ? 8 : null,
          right: alignment == Alignment.topRight || alignment == Alignment.bottomRight ? 8 : null,
          child: PromotionBadge(isPromotion: isPromotion, size: size),
        ),
      ],
    );
  }
}
