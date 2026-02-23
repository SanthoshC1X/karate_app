import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/post_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/dashboard_cards.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(allStudentsProvider);
    final locationsAsync = ref.watch(locationsProvider);
    final postsAsync = ref.watch(postsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: AppText.r.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textOnDark,
              ),
            ),
            Text(
              'Welcome back, Sensei',
              style: AppText.s.copyWith(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) context.go('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(allStudentsProvider);
          ref.invalidate(locationsProvider);
          ref.invalidate(postsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Stats row
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    icon: Icons.people,
                    label: 'Students',
                    value: studentsAsync.when(
                      data: (s) => '${s.length}',
                      loading: () => '—',
                      error: (_, __) => '?',
                    ),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    icon: Icons.location_on,
                    label: 'Locations',
                    value: locationsAsync.when(
                      data: (l) => '${l.length}',
                      loading: () => '—',
                      error: (_, __) => '?',
                    ),
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    icon: Icons.article_outlined,
                    label: 'Posts',
                    value: postsAsync.when(
                      data: (p) => '${p.length}',
                      loading: () => '—',
                      error: (_, __) => '?',
                    ),
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    icon: Icons.upcoming_outlined,
                    label: 'Upcoming',
                    value: postsAsync.when(
                      data: (p) =>
                          '${p.where((e) => e.isUpcoming).length}',
                      loading: () => '—',
                      error: (_, __) => '?',
                    ),
                    color: AppColors.accentPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Quick Actions',
              style: AppText.section.copyWith(color: AppColors.textOnDark),
            ),
            const SizedBox(height: 14),
            DashboardActionCard(
              icon: Icons.fact_check,
              label: 'Mark Attendance',
              subtitle: 'Record today\'s class',
              color: AppColors.primary,
              onTap: () => context.go('/admin/attendance'),
            ),
            const SizedBox(height: 10),
            DashboardActionCard(
              icon: Icons.post_add,
              label: 'Create Post',
              subtitle: 'Share an event or update',
              color: AppColors.info,
              onTap: () => context.go('/admin/posts/create'),
            ),
            const SizedBox(height: 10),
            DashboardActionCard(
              icon: Icons.people,
              label: 'View Students',
              subtitle: 'Browse all students',
              color: AppColors.success,
              onTap: () => context.go('/admin/students'),
            ),
            const SizedBox(height: 10),
            DashboardActionCard(
              icon: Icons.add_location_alt,
              label: 'Manage Locations',
              subtitle: 'Add or edit apartments',
              color: AppColors.accentPurple,
              onTap: () => context.go('/admin/locations'),
            ),
          ],
        ),
      ),
    );
  }
}

