import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
            surfaceContainerHighest: AppColors.surfaceTint,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.surface,
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: AppColors.surface,
            headerBackgroundColor: AppColors.surface,
            headerForegroundColor: AppColors.textPrimary,
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.onPrimary;
              }
              if (states.contains(WidgetState.disabled)) {
                return AppColors.textDisabled;
              }
              return AppColors.textPrimary;
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return null;
            }),
            todayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.onPrimary;
              }
              return AppColors.primary;
            }),
            todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return null;
            }),
            todayBorder: const BorderSide(color: AppColors.primary, width: 1.5),
            dayOverlayColor: WidgetStatePropertyAll(
              AppColors.primary.withValues(alpha: 0.08),
            ),
            yearForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.onPrimary;
              }
              return AppColors.textPrimary;
            }),
            yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return null;
            }),
            yearOverlayColor: WidgetStatePropertyAll(
              AppColors.primary.withValues(alpha: 0.08),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            headerHeadlineStyle: AppText.h1.copyWith(color: AppColors.textPrimary),
            headerHelpStyle: AppText.bodyMedium.copyWith(color: AppColors.primary),
            weekdayStyle: AppText.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            dayStyle: AppText.bodyMedium,
            yearStyle: AppText.bodyMedium,
            cancelButtonStyle: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              textStyle: AppText.button,
              minimumSize: const Size(100, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            confirmButtonStyle: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              textStyle: AppText.button,
              minimumSize: const Size(100, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        child: child!,
      ),
    );
  }
}

class AppDatePickerField extends StatelessWidget {
  final String label;
  final String? valueText;
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final IconData icon;
  final String placeholder;

  const AppDatePickerField({
    super.key,
    required this.label,
    this.valueText,
    this.selectedDate,
    required this.onTap,
    this.onClear,
    this.icon = Icons.calendar_today_rounded,
    this.placeholder = 'Select a date',
  });

  String get _displayText {
    if (valueText != null) return valueText!;
    if (selectedDate != null) {
      return DateFormat('EEEE, MMMM d, yyyy').format(selectedDate!);
    }
    return placeholder;
  }

  bool get _hasValue => valueText != null || selectedDate != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _hasValue
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : AppColors.field,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _hasValue
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.borderInput,
                  width: _hasValue ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _hasValue
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: _hasValue ? AppColors.primary : AppColors.textHint,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _displayText,
                      style: _hasValue
                          ? AppText.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            )
                          : AppText.bodyMedium.copyWith(
                              color: AppColors.textHint,
                            ),
                    ),
                  ),
                  if (_hasValue && onClear != null)
                    GestureDetector(
                      onTap: onClear,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.textHint.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary, size: 16),
                      ),
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textHint,
                      size: 14,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
