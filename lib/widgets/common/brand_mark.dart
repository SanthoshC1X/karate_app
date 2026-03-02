import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  final double size;
  final double iconSize;
  final double glowOpacity;
  final String assetPath;

  const BrandMark({
    super.key,
    this.size = 80,
    this.iconSize = 42,
    this.glowOpacity = 0.4,
    this.assetPath = 'assets/MentorX_logo.png',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: glowOpacity),
            blurRadius: 30,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.sports_martial_arts,
            color: AppColors.onPrimary,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
