import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/belt_badge.dart';
import '../../widgets/attendance_tile.dart';
import '../../widgets/common/app_skeleton_loading.dart';

class StudentDetailScreen extends ConsumerWidget {
  final String studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentDetailProvider(studentId));
    final attendanceAsync = ref.watch(studentAttendanceProvider(studentId));
    final statsAsync = ref.watch(studentAttendanceStatsProvider(studentId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: studentAsync.when(
        loading: () => const _StudentDetailSkeleton(),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
        data: (student) {
          if (student == null) {
            return const Center(
                child: Text('Student not found',
                    style: TextStyle(color: AppColors.textOnDark54)));
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.surface,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha:0.7),
                          AppColors.surface,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor:
                              AppColors.onPrimary.withValues(alpha:0.15),
                          child: Text(
                            student.name[0].toUpperCase(),
                            style: const TextStyle(
                                fontSize: 36,
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          student.name,
                          style: AppText.titleMd.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onPrimary),
                        ),
                        const SizedBox(height: 6),
                        BeltBadge(beltLevel: student.beltLevel),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info cards
                      _InfoRow(icon: Icons.email_outlined,
                          label: 'Email', value: 'Loaded from mock API'),
                      if (student.phone != null)
                        _InfoRow(icon: Icons.phone_outlined,
                            label: 'Phone', value: student.phone!),
                      if (student.age != null)
                        _InfoRow(icon: Icons.cake_outlined,
                            label: 'Age', value: '${student.age} years old'),
                      const SizedBox(height: 20),
                      // Attendance stats
                      statsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: AppSkeletonLoading(height: 92, width: double.infinity),
                        ),
                        error: (_, __) => const SizedBox(),
                        data: (stats) {
                          final total = stats['total'] ?? 0;
                          final present = stats['present'] ?? 0;
                          final pct = total == 0
                              ? 0
                              : ((present / total) * 100).round();
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _AttendanceStat(
                                    label: 'Total',
                                    value: '$total',
                                    color: AppColors.textOnDark),
                                _AttendanceStat(
                                    label: 'Present',
                                    value: '$present',
                                    color: AppColors.success),
                                _AttendanceStat(
                                    label: 'Absent',
                                    value: '${total - present}',
                                    color: AppColors.error),
                                _AttendanceStat(
                                    label: 'Rate',
                                    value: '$pct%',
                                    color: pct >= 75
                                        ? AppColors.success
                                        : AppColors.warningDeep),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text('Attendance History',
                          style: AppText.section.copyWith(
                              color: AppColors.textOnDark)),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              attendanceAsync.when(
                loading: () => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: const [
                        AppSkeletonListItem(height: 74),
                        AppSkeletonListItem(height: 74),
                        AppSkeletonListItem(height: 74),
                      ],
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                    child: Center(child: Text('$e',
                        style: const TextStyle(color: AppColors.error)))),
                data: (records) {
                  if (records.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No attendance records',
                            style: TextStyle(color: AppColors.textOnDark54)),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => AttendanceTile(attendance: records[i]),
                      childCount: records.length,
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          );
        },
      ),
    );
  }
}

class _StudentDetailSkeleton extends StatelessWidget {
  const _StudentDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: AppSkeletonLoading(
            height: 220,
            width: double.infinity,
            borderRadius: BorderRadius.zero,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppSkeletonLoading(width: 210, height: 14),
                SizedBox(height: 12),
                AppSkeletonLoading(width: 170, height: 14),
                SizedBox(height: 12),
                AppSkeletonLoading(width: 140, height: 14),
                SizedBox(height: 20),
                AppSkeletonLoading(height: 92, width: double.infinity),
                SizedBox(height: 24),
                AppSkeletonLoading(width: 160, height: 16),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                AppSkeletonListItem(height: 74),
                AppSkeletonListItem(height: 74),
                AppSkeletonListItem(height: 74),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: AppColors.textOnDark38, fontSize: 11)),
              Text(value,
                  style: const TextStyle(color: AppColors.textOnDark, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AttendanceStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: const TextStyle(color: AppColors.textOnDark54, fontSize: 12)),
      ],
    );
  }
}

