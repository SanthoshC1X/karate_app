import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class AttendanceTile extends StatelessWidget {
  final AttendanceModel attendance;

  const AttendanceTile({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    final isPresent = attendance.isPresent;
    final statusColor = isPresent ? AppColors.success : AppColors.error;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.12),
            ),
            child: Icon(
              isPresent ? Icons.check_rounded : Icons.close_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE, MMM d yyyy').format(attendance.date),
                  style: AppText.bodyMedium,
                ),
                if (attendance.locationName != null)
                  Text(
                    attendance.locationName!,
                    style: AppText.caption,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isPresent ? 'Present' : 'Absent',
              style: AppText.label.copyWith(color: statusColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
