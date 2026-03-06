import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/post_model.dart';
import '../../providers/post_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_buttons.dart';
import '../../widgets/common/app_date_picker.dart';
import '../../widgets/common/app_skeleton_loading.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/common/app_snackbar.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchPosts();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _switchPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Posts',
            style: AppText.titleMd.copyWith(color: AppColors.textOnDark)),
      ),
      body: Column(
        children: [
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Post Live',
                    icon: Icons.public,
                    selected: _currentPage == 0,
                    onTap: () => _switchPage(0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TabButton(
                    label: 'Create Post',
                    icon: Icons.add_circle_outline,
                    selected: _currentPage == 1,
                    onTap: () => _switchPage(1),
                  ),
                ),
              ],
            ),
          ),
          // Page view
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: const [
                _PostLiveTab(),
                _CreatePostTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Button ───

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLighter,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color:
                    selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppText.m.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Post Live Tab ───

class _PostLiveTab extends StatelessWidget {
  const _PostLiveTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostProvider>();
    final posts = provider.posts;

    if (provider.isLoading && posts.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (_, __) => const _PostSkeleton(),
      );
    }

    if (provider.error != null && posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(provider.error!,
                style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            AppMutedButton(
              label: 'Retry',
              onPressed: () => context.read<PostProvider>().fetchPosts(),
            ),
          ],
        ),
      );
    }

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.article_outlined,
                size: 64, color: AppColors.textOnDark30),
            const SizedBox(height: 16),
            Text('No posts yet',
                style: AppText.m.copyWith(color: AppColors.textOnDark54)),
            const SizedBox(height: 4),
            Text('Create your first post to see it here.',
                style: AppText.s.copyWith(color: AppColors.textHint)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () => context.read<PostProvider>().fetchPosts(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: posts.length,
        itemBuilder: (_, i) => _PostCard(post: posts[i]),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostModel post;
  const _PostCard({required this.post});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Post',
            style: AppText.titleMd.copyWith(color: AppColors.textOnDark)),
        content: Text(
          'Are you sure you want to delete "${post.title}"? This action cannot be undone.',
          style: AppText.m.copyWith(color: AppColors.textOnDark54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await context.read<PostProvider>().deletePost(post.id);
        if (context.mounted) {
          AppSnackbar.show(
            context: context,
            type: AppSnackbarType.success,
            title: 'Deleted',
            message: 'Post deleted successfully.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.show(
            context: context,
            type: AppSnackbarType.error,
            title: 'Error',
            message: e.toString().replaceAll('Exception: ', ''),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLighter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.imageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: CachedNetworkImage(
                imageUrl: post.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 160,
                  color: AppColors.fieldDark,
                  child: const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 160,
                  color: AppColors.fieldDark,
                  child: const Icon(Icons.image_not_supported,
                      color: AppColors.textOnDark30, size: 36),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: post.isUpcoming
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        post.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: post.isUpcoming
                              ? AppColors.primary
                              : AppColors.success,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d, yyyy').format(post.createdAt),
                      style: AppText.s.copyWith(
                          color: AppColors.textHint, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: AppColors.error, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  post.title,
                  style: AppText.m.copyWith(
                    color: AppColors.textOnDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post.description != null &&
                    post.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    post.description!,
                    style: AppText.s.copyWith(
                      color: AppColors.textOnDark54,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (post.date != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: AppColors.textHint),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMMM d, yyyy').format(post.date!),
                        style: AppText.s.copyWith(
                            color: AppColors.textHint, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostSkeleton extends StatelessWidget {
  const _PostSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(14),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppSkeletonLoading(width: 70, height: 20),
                Spacer(),
                AppSkeletonLoading(width: 80, height: 12),
              ],
            ),
            SizedBox(height: 12),
            AppSkeletonLoading(width: double.infinity, height: 16),
            SizedBox(height: 8),
            AppSkeletonLoading(width: 200, height: 12),
          ],
        ),
      ),
    );
  }
}

// ─── Create Post Tab ───

class _CreatePostTab extends StatefulWidget {
  const _CreatePostTab();

  @override
  State<_CreatePostTab> createState() => _CreatePostTabState();
}

class _CreatePostTabState extends State<_CreatePostTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _eventDate;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await AppDatePicker.pick(
      context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2040),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (!mounted) return;
      await context.read<PostProvider>().createPost(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
            date: _eventDate,
            type: 'upcoming',
          );
      if (!mounted) return;
      AppSnackbar.show(
        context: context,
        type: AppSnackbarType.success,
        title: 'Success',
        message: 'Post created successfully.',
      );
      _titleCtrl.clear();
      _descCtrl.clear();
      setState(() {
        _eventDate = null;
      });
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context: context,
          type: AppSnackbarType.error,
          title: 'Create Post Failed',
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _loading,
      message: 'Publishing post...',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title
            TextFormField(
              controller: _titleCtrl,
              style: AppText.body.copyWith(color: AppColors.textOnDark),
              decoration: const InputDecoration(
                labelText: 'Title *',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.title, color: AppColors.textHint),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 14),
            // Description
            TextFormField(
              controller: _descCtrl,
              style: AppText.body.copyWith(color: AppColors.textOnDark),
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                alignLabelWithHint: true,
                prefixIcon:
                    Icon(Icons.description_outlined, color: AppColors.textHint),
              ),
            ),
            const SizedBox(height: 14),
            // Date
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.fieldDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: AppColors.textHint, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _eventDate == null
                          ? 'Pick event date (optional)'
                          : DateFormat('MMMM d, yyyy').format(_eventDate!),
                      style: TextStyle(
                        color: _eventDate == null
                            ? AppColors.textHint
                            : AppColors.textOnDark,
                      ),
                    ),
                    if (_eventDate != null) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _eventDate = null),
                        child: const Icon(Icons.close,
                            color: AppColors.textHint, size: 18),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            AppLoadingButton(
              label: 'Publish Post',
              isLoading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
