import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_skeleton_loading.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchPostDetail(widget.postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostProvider>();
    final post = provider.getPostDetail(widget.postId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: provider.isLoading && post == null
          ? const _PostDetailSkeleton()
          : post == null
              ? Center(
                  child: Text(
                    provider.error ?? 'Post not found',
                    style: AppText.m.copyWith(color: AppColors.textSecondary),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: post.imageUrl != null ? 280 : 120,
                      pinned: true,
                      backgroundColor: AppColors.surface,
                      flexibleSpace: FlexibleSpaceBar(
                        background: post.imageUrl != null
                            ? Hero(
                                tag: 'post-${post.id}',
                                child: CachedNetworkImage(
                                  imageUrl: post.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: AppColors.surface),
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.surface,
                                    child: const Icon(Icons.image_not_supported,
                                        color: AppColors.textOnDark30, size: 48),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [AppColors.primary, AppColors.surface],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.article, color: AppColors.textOnDark38, size: 64),
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: post.isUpcoming
                                        ? AppColors.primary.withValues(alpha: 0.2)
                                        : AppColors.success.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: post.isUpcoming ? AppColors.primary : AppColors.success,
                                      width: 0.7,
                                    ),
                                  ),
                                  child: Text(
                                    post.isUpcoming ? 'Upcoming' : 'Recent',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: post.isUpcoming ? AppColors.primary : AppColors.success,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (post.date != null)
                                  Text(
                                    DateFormat('MMMM d, yyyy').format(post.date!),
                                    style: AppText.bodyMuted.copyWith(fontSize: 13),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              post.title,
                              style: AppText.h2.copyWith(fontSize: 24, color: AppColors.textOnDark),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Posted ${DateFormat('MMM d, yyyy').format(post.createdAt)}',
                              style: AppText.s.copyWith(color: AppColors.textHint, fontSize: 12),
                            ),
                            if (post.description != null && post.description!.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              const Divider(color: AppColors.borderLighter),
                              const SizedBox(height: 16),
                              Text(
                                post.description!,
                                style: AppText.m.copyWith(
                                  color: AppColors.textOnDark.withValues(alpha: 0.7),
                                  fontSize: 15,
                                  height: 1.6,
                                ),
                              ),
                            ],
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _PostDetailSkeleton extends StatelessWidget {
  const _PostDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: AppSkeletonLoading(
            height: 280,
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
                Row(
                  children: [
                    AppSkeletonLoading(width: 96, height: 24),
                    Spacer(),
                    AppSkeletonLoading(width: 120, height: 12),
                  ],
                ),
                SizedBox(height: 16),
                AppSkeletonLoading(width: 260, height: 24),
                SizedBox(height: 8),
                AppSkeletonLoading(width: 150, height: 12),
                SizedBox(height: 20),
                AppSkeletonLoading(width: double.infinity, height: 12),
                SizedBox(height: 8),
                AppSkeletonLoading(width: double.infinity, height: 12),
                SizedBox(height: 8),
                AppSkeletonLoading(width: 220, height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
