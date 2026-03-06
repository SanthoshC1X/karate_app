import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/dashboard_cards.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = context.read<UserProvider>();
      final locationProvider = context.read<LocationProvider>();
      final postProvider = context.read<PostProvider>();
      await userProvider.fetchAllStudents();
      await locationProvider.fetchLocations();
      await postProvider.fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final users = context.watch<UserProvider>();
    final locations = context.watch<LocationProvider>();
    final posts = context.watch<PostProvider>();
    final isSuperAdmin = auth.currentUser?.member == 'super_admin';
    final heading = isSuperAdmin ? 'Super Admin Dashboard' : 'Master Dashboard';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
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
              await context.read<AuthProvider>().signOut();
              if (context.mounted) context.go('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          final userProvider = context.read<UserProvider>();
          final locationProvider = context.read<LocationProvider>();
          final postProvider = context.read<PostProvider>();
          await userProvider.fetchAllStudents();
          await locationProvider.fetchLocations();
          await postProvider.fetchPosts();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    icon: Icons.people,
                    label: 'Students',
                    value: users.isLoading ? '--' : '${users.students.length}',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    icon: Icons.location_on,
                    label: 'Locations',
                    value: locations.isLoading ? '--' : '${locations.locations.length}',
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
                    value: posts.isLoading ? '--' : '${posts.posts.length}',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    icon: Icons.payment_outlined,
                    label: 'Payments',
                    value: 'Not Yet',
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
