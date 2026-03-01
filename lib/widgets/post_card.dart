import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/post_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'common/app_skeleton_loading.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;

  const PostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  height: 175,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const AppSkeletonLoading(
                    height: 175,
                    width: double.infinity,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 175,
                    color: AppColors.surfaceTint,
                    child: const Icon(Icons.image_not_supported,
                        color: AppColors.textHint, size: 40),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TypeChip(isUpcoming: post.isUpcoming),
                      const Spacer(),
                      if (post.date != null)
                        Text(
                          DateFormat('MMM d, yyyy').format(post.date!),
                          style: AppText.caption,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(post.title, style: AppText.h3),
                  if (post.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      post.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final bool isUpcoming;
  const _TypeChip({required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    final color = isUpcoming ? AppColors.primary : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        isUpcoming ? 'Upcoming' : 'Recent',
        style: AppText.label.copyWith(color: color, fontSize: 11),
      ),
    );
  }
}
