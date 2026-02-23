import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BeltBadge extends StatelessWidget {
  final String beltLevel;
  final double size;

  const BeltBadge({super.key, required this.beltLevel, this.size = 14});

  Color get _beltColor {
    switch (beltLevel.toLowerCase()) {
      case 'white':
        return AppColors.textPrimary;
      case 'yellow':
        return const Color(0xFFFDD835);
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'brown':
        return const Color(0xFF795548);
      case 'black':
        return Colors.black87;
      default:
        return Colors.grey;
    }
  }

  Color get _textColor {
    switch (beltLevel.toLowerCase()) {
      case 'white':
      case 'yellow':
        return Colors.black87;
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
          color: Colors.black26,
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
