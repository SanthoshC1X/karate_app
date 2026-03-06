import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import 'app_card.dart';
import 'step_card.dart';

class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppText.h1.copyWith(
              fontSize: 28,
              color: AppColors.textOnDark,
            ),
          ),
          Text(
            label,
            style: AppText.bodyMuted.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Adaptive card showing a count stat (e.g. Classes).
/// Uses [LayoutBuilder] so sizes scale with available width.
class StudentStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const StudentStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        final iconSize = (w * 0.13).clamp(18.0, 26.0);
        final iconBoxSize = (w * 0.24).clamp(34.0, 48.0);
        final valueFontSize = (w * 0.17).clamp(20.0, 30.0);
        final labelFontSize = (w * 0.08).clamp(10.0, 13.0);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: iconSize),
              ),
              SizedBox(height: w * 0.07),
              Text(
                value,
                style: AppText.h2.copyWith(
                  fontSize: valueFontSize,
                  color: AppColors.textOnDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppText.s.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: labelFontSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Adaptive card showing attendance percentage + present/total count.
class StudentAttendanceCard extends StatelessWidget {
  final double pct;
  final int pctInt;
  final int present;
  final int total;

  const StudentAttendanceCard({
    super.key,
    required this.pct,
    required this.pctInt,
    required this.present,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        final indicatorRadius = (w * 0.19).clamp(26.0, 40.0);
        final lineWidth = (w * 0.035).clamp(4.0, 6.5);
        final pctFontSize = (w * 0.075).clamp(9.0, 13.0);
        final valueFontSize = (w * 0.14).clamp(18.0, 26.0);
        final labelFontSize = (w * 0.08).clamp(10.0, 13.0);

        final color = pctInt >= 75 ? AppColors.success : AppColors.warningDeep;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (pctInt >= 75 ? AppColors.success : AppColors.warningDeep)
                  .withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircularPercentIndicator(
                radius: indicatorRadius,
                lineWidth: lineWidth,
                animation: true,
                percent: pct.clamp(0.0, 1.0),
                center: Text(
                  '$pctInt%',
                  style: AppText.r.copyWith(
                    fontSize: pctFontSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                progressColor: color,
                backgroundColor: AppColors.borderLighter,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              SizedBox(height: w * 0.06),
              Text(
                '$present / $total',
                style: AppText.h2.copyWith(
                  fontSize: valueFontSize,
                  color: AppColors.textOnDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Attendance',
                style: AppText.s.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: labelFontSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const DashboardActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StepCard(
      icon: icon,
      title: label,
      subtitle: subtitle,
      color: color,
      onTap: onTap,
    );
  }
}
