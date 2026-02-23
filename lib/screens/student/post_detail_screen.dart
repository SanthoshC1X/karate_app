import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/post_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: postAsync.when(
        loading: () => const Center(
            child:
                CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) =>
            Center(child: Text('$e', style: AppText.m.copyWith(color: AppColors.error))),
        data: (post) {
          if (post == null) {
            return Center(
                child: Text('Post not found',
                    style: AppText.m.copyWith(color: AppColors.textSecondary)));
          }
          return CustomScrollView(
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
                            placeholder: (_, __) => Container(
                              color: AppColors.surface,
                            ),
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
                              colors: [
                                AppColors.primary,
                                AppColors.surface
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.article,
                                color: AppColors.textOnDark38, size: 64),
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
                      // Type badge + date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: post.isUpcoming
                                  ? AppColors.primary.withValues(alpha:0.2)
                                  : AppColors.success.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: post.isUpcoming
                                    ? AppColors.primary
                                    : AppColors.success,
                                width: 0.7,
                              ),
                            ),
                            child: Text(
                              post.isUpcoming ? '🗓 Upcoming' : '🏆 Recent',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: post.isUpcoming
                                    ? AppColors.primary
                                    : AppColors.success,
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
                        style: AppText.h2.copyWith(
                          fontSize: 24,
                          color: AppColors.textOnDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Posted ${DateFormat('MMM d, yyyy').format(post.createdAt)}',
                        style: AppText.s.copyWith(
                            color: AppColors.textHint, fontSize: 12),
                      ),
                      if (post.description != null &&
                          post.description!.isNotEmpty) ...[
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
          );
        },
      ),
    );
  }
}


