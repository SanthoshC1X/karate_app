import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/attendance_tile.dart';
import '../../widgets/common/app_skeleton_loading.dart';

class MyAttendanceScreen extends StatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  State<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends State<MyAttendanceScreen> {
  String _uid = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _uid = context.read<AuthProvider>().currentUserId ?? '';
      if (_uid.isEmpty) return;
      await context.read<AttendanceProvider>().fetchStudentAttendance(_uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final records = _uid.isEmpty ? const [] : attendanceProvider.getStudentAttendance(_uid);
    final stats = _uid.isEmpty ? const {'total': 0, 'present': 0} : attendanceProvider.getStudentStats(_uid);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Attendance', style: AppText.titleMd.copyWith(color: AppColors.textOnDark)),
      ),
      body: Column(
        children: [
          if (attendanceProvider.isLoading && records.isEmpty)
            const _AttendanceStatsSkeleton()
          else
            Builder(
              builder: (_) {
                final total = stats['total'] ?? 0;
                final present = stats['present'] ?? 0;
                final pct = total == 0 ? 0.0 : present / total;
                final pctInt = (pct * 100).round();
                return Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: pctInt >= 75
                          ? AppColors.success.withValues(alpha: 0.4)
                          : AppColors.warningDeep.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircularPercentIndicator(
                        radius: 55,
                        lineWidth: 8,
                        animation: true,
                        percent: pct.clamp(0.0, 1.0),
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$pctInt%',
                              style: AppText.h2.copyWith(
                                fontSize: 20,
                                color: pctInt >= 75 ? AppColors.success : AppColors.warningDeep,
                              ),
                            ),
                            Text('Attend.', style: AppText.s.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                          ],
                        ),
                        progressColor: pctInt >= 75 ? AppColors.success : AppColors.warningDeep,
                        backgroundColor: AppColors.borderLighter,
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StatRow(label: 'Total Sessions', value: '$total', color: AppColors.textOnDark),
                            const SizedBox(height: 8),
                            _StatRow(label: 'Present', value: '$present', color: AppColors.success),
                            const SizedBox(height: 8),
                            _StatRow(label: 'Absent', value: '${total - present}', color: AppColors.error),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('History', style: AppText.section.copyWith(color: AppColors.textOnDark)),
            ),
          ),
          Expanded(
            child: attendanceProvider.isLoading && records.isEmpty
                ? const _AttendanceListSkeleton()
                : records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.event_busy, size: 64, color: AppColors.textOnDark30),
                            const SizedBox(height: 16),
                            Text('No attendance recorded yet',
                                style: AppText.m.copyWith(color: AppColors.textSecondary, fontSize: 15)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          if (_uid.isEmpty) return;
                          await context.read<AttendanceProvider>().fetchStudentAttendance(_uid);
                        },
                        child: ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (_, i) => AttendanceTile(attendance: records[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.bodyMuted),
        Text(value, style: AppText.r.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _AttendanceStatsSkeleton extends StatelessWidget {
  const _AttendanceStatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Row(
        children: [
          AppSkeletonLoading(
            width: 110,
            height: 110,
            borderRadius: BorderRadius.all(Radius.circular(55)),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                AppSkeletonLoading(height: 12, width: double.infinity),
                SizedBox(height: 10),
                AppSkeletonLoading(height: 12, width: double.infinity),
                SizedBox(height: 10),
                AppSkeletonLoading(height: 12, width: double.infinity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceListSkeleton extends StatelessWidget {
  const _AttendanceListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 6),
      itemCount: 6,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: AppSkeletonListItem(height: 74),
      ),
    );
  }
}
