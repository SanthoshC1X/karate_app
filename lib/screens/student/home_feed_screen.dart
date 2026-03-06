import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_skeleton_loading.dart';
import '../../widgets/common/dashboard_cards.dart';
import '../../widgets/post_card.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  String _uid = '';
  final Set<String> _dismissed = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _uid = context.read<AuthProvider>().currentUserId ?? '';
      context.read<PostProvider>().fetchPosts();
      if (_uid.isNotEmpty) {
        context.read<AttendanceProvider>().fetchStudentAttendance(_uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    final stats = _uid.isEmpty
        ? const {'total': 0, 'present': 0}
        : attendanceProvider.getStudentStats(_uid);
    final total = stats['total'] ?? 0;
    final present = stats['present'] ?? 0;
    final pct = total == 0 ? 0.0 : present / total;
    final pctInt = (pct * 100).round();

    final posts = postProvider.posts
        .where((p) => !_dismissed.contains(p.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MentorX',
              style: AppText.r.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.textOnDark,
              ),
            ),
            if (user != null)
              Text(
                'Hello, ${user.name.split(' ').first}',
                style: AppText.s.copyWith(fontSize: 11, color: AppColors.textSecondary),
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
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          context.read<PostProvider>().fetchPosts();
          if (_uid.isNotEmpty) {
            await context.read<AttendanceProvider>().fetchStudentAttendance(_uid);
          }
        },
        child: CustomScrollView(
          slivers: [
            // ── Dashboard ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: attendanceProvider.isLoading && total == 0
                    ? const _DashboardSkeleton()
                    : Row(
                        children: [
                          Expanded(
                            child: StudentStatCard(
                              icon: Icons.fitness_center_rounded,
                              label: 'Classes',
                              value: '$total',
                              color: AppColors.primary,
                              bgColor: AppColors.primaryLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StudentAttendanceCard(
                              pct: pct,
                              pctInt: pctInt,
                              present: present,
                              total: total,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // ── Posts header ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'From Your Instructor',
                  style: AppText.section.copyWith(color: AppColors.textOnDark),
                ),
              ),
            ),

            // ── Posts list ────────────────────────────────────────────
            if (postProvider.isLoading && posts.isEmpty)
              const SliverToBoxAdapter(child: _PostsSkeleton())
            else if (postProvider.error != null)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      postProvider.error!,
                      style: AppText.m.copyWith(color: AppColors.error),
                    ),
                  ),
                ),
              )
            else if (posts.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        const Icon(Icons.article_outlined,
                            size: 64, color: AppColors.textOnDark30),
                        const SizedBox(height: 16),
                        Text('No posts yet',
                            style: AppText.m.copyWith(
                                color: AppColors.textSecondary, fontSize: 15)),
                        const SizedBox(height: 8),
                        Text('Your instructor will post updates here',
                            style: AppText.s.copyWith(
                                color: AppColors.textHint, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final post = posts[i];
                    return Dismissible(
                      key: ValueKey(post.id),
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.error, size: 28),
                      ),
                      onDismissed: (_) {
                        setState(() => _dismissed.add(post.id));
                      },
                      child: PostCard(
                        post: post,
                        onTap: () => ctx.go('/student/posts/${post.id}'),
                      ),
                    );
                  },
                  childCount: posts.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

// ── Skeletons ─────────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonLoading(
                    width: 38, height: 38, borderRadius: BorderRadius.all(Radius.circular(19))),
                SizedBox(height: 12),
                AppSkeletonLoading(width: 50, height: 22),
                SizedBox(height: 6),
                AppSkeletonLoading(width: 80, height: 12),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonLoading(
                    width: 60, height: 60, borderRadius: BorderRadius.all(Radius.circular(30))),
                SizedBox(height: 10),
                AppSkeletonLoading(width: 50, height: 18),
                SizedBox(height: 6),
                AppSkeletonLoading(width: 80, height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PostsSkeleton extends StatelessWidget {
  const _PostsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSkeletonLoading(
              height: 160,
              width: double.infinity,
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonLoading(width: 90, height: 18),
                  SizedBox(height: 10),
                  AppSkeletonLoading(width: 220, height: 14),
                  SizedBox(height: 8),
                  AppSkeletonLoading(width: 160, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
