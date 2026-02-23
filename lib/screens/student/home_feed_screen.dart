import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/post_model.dart';
import '../../providers/post_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/post_card.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Karate Class',
                style: AppText.r.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppColors.textOnDark)),
            Text('Community Feed',
                style: AppText.s.copyWith(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
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
            Tab(text: '🗓 Upcoming'),
            Tab(text: '🏆 Recent'),
          ],
        ),
      ),
      body: postsAsync.when(
        loading: () => const Center(
            child:
                CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) =>
            Center(child: Text('$e', style: AppText.m.copyWith(color: AppColors.error))),
        data: (posts) {
          final upcoming =
              posts.where((p) => p.type == 'upcoming').toList();
          final recent = posts.where((p) => p.type == 'recent').toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(postsProvider),
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
            Text('No posts yet',
                style: AppText.m.copyWith(color: AppColors.textSecondary, fontSize: 15)),
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

