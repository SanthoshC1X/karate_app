import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';
import '../theme/app_colors.dart';

class AttendanceTile extends StatelessWidget {
  final AttendanceModel attendance;

  const AttendanceTile({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: attendance.isPresent
              ? AppColors.success.withValues(alpha:0.4)
              : AppColors.error.withValues(alpha:0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: attendance.isPresent
                  ? AppColors.success.withValues(alpha:0.15)
                  : AppColors.error.withValues(alpha:0.15),
            ),
            child: Icon(
              attendance.isPresent ? Icons.check : Icons.close,
              color: attendance.isPresent ? AppColors.success : AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d yyyy').format(attendance.date),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (attendance.locationName != null)
                  Text(
                    attendance.locationName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            attendance.isPresent ? 'Present' : 'Absent',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: attendance.isPresent ? AppColors.success : AppColors.error,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
