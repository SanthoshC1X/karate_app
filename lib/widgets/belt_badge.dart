import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BeltBadge extends StatelessWidget {
  final String beltLevel;
  final double size;

  const BeltBadge({super.key, required this.beltLevel, this.size = 14});

  Color get _beltColor {
    switch (beltLevel.toLowerCase()) {
      case 'white':
        return AppColors.white1;
      case 'yellow':
        return AppColors.warning.withValues(alpha: 0.2);
      case 'orange':
        return AppColors.skin8.withValues(alpha: 0.2);
      case 'green':
        return AppColors.success.withValues(alpha: 0.2);
      case 'blue':
        return AppColors.primary;
      case 'brown':
        return AppColors.skin10;
      case 'black':
        return AppColors.text1;
      default:
        return AppColors.white8;
    }
  }

  Color get _textColor {
    switch (beltLevel.toLowerCase()) {
      case 'white':
      case 'yellow':
        return AppColors.text1;
      default:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _beltColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _beltColor.withValues(alpha:0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        beltLevel,
        style: TextStyle(
          color: _textColor,
          fontSize: size,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
