import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class AppDatePicker {
  static Future<DateTime?> pick(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
          textTheme: Theme.of(ctx).textTheme.copyWith(
                titleLarge: AppText.h2,
                bodyMedium: AppText.m,
              ),
        ),
        child: child!,
      ),
    );
  }
}

class AppDatePickerField extends StatelessWidget {
  final String label;
  final String valueText;
  final VoidCallback onTap;
  final IconData icon;

  const AppDatePickerField({
    super.key,
    required this.label,
    required this.valueText,
    required this.onTap,
    this.icon = Icons.calendar_today,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textHint.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.s),
                  const SizedBox(height: 2),
                  Text(valueText, style: AppText.m),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
