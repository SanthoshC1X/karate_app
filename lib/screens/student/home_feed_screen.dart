import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_skeleton_loading.dart';
import '../../widgets/post_card.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchPosts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Karate Class',
              style: AppText.r.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.textOnDark,
              ),
            ),
            Text(
              'Community Feed',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          labelStyle: AppText.m.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Recent'),
          ],
        ),
      ),
      body: postProvider.isLoading
          ? const _HomeFeedSkeleton()
          : postProvider.error != null
              ? Center(
                  child: Text(
                    postProvider.error!,
                    style: AppText.m.copyWith(color: AppColors.error),
                  ),
                )
              : Builder(
                  builder: (_) {
                    final upcoming = postProvider.posts.where((p) => p.type == 'upcoming').toList();
                    final recent = postProvider.posts.where((p) => p.type == 'recent').toList();
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => context.read<PostProvider>().fetchPosts(),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _PostList(posts: upcoming),
                          _PostList(posts: recent),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _HomeFeedSkeleton extends StatelessWidget {
  const _HomeFeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: 4,
      itemBuilder: (_, __) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonLoading(
                  height: 180,
                  width: double.infinity,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
        ],
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  final List<PostModel> posts;

  const _PostList({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article_outlined, size: 64, color: AppColors.textOnDark30),
            const SizedBox(height: 16),
            Text('No posts yet', style: AppText.m.copyWith(color: AppColors.textSecondary, fontSize: 15)),
            const SizedBox(height: 8),
            Text('Your instructor will post updates here',
                style: AppText.s.copyWith(color: AppColors.textHint, fontSize: 13)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: posts.length,
      itemBuilder: (ctx, i) => PostCard(
        post: posts[i],
        onTap: () => ctx.go('/student/posts/${posts[i].id}'),
      ),
    );
  }
}
