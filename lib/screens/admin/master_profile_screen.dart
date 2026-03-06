import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class MasterProfileScreen extends StatefulWidget {
  const MasterProfileScreen({super.key});

  @override
  State<MasterProfileScreen> createState() => _MasterProfileScreenState();
}

class _MasterProfileScreenState extends State<MasterProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Profile',
            style: AppText.titleMd.copyWith(color: AppColors.textOnDark)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: 'Logout',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Text('Logout',
                      style: AppText.titleMd
                          .copyWith(color: AppColors.textOnDark)),
                  content: Text('Are you sure you want to logout?',
                      style:
                          AppText.m.copyWith(color: AppColors.textOnDark54)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('Cancel',
                          style:
                              TextStyle(color: AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Logout',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
      body: auth.isLoading && user == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : user == null
              ? Center(
                  child: Text(auth.error ?? 'Could not load profile',
                      style: AppText.m
                          .copyWith(color: AppColors.textSecondary)),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<AuthProvider>().loadProfile(),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Avatar + Name
                      Center(
                        child: Column(
                          children: [
                            _ProfileAvatar(
                              name: user.name,
                              imageUrl: user.profilePictureUrl,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user.name,
                              style: AppText.h1
                                  .copyWith(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user.member == 'super_admin'
                                    ? 'Super Admin'
                                    : 'Master',
                                style: AppText.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Info card
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _ProfileInfoTile(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: user.email ?? 'Not provided',
                            ),
                            const Divider(
                                height: 1, color: AppColors.borderLight),
                            _ProfileInfoTile(
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              value: user.phone ?? 'Not provided',
                            ),
                            const Divider(
                                height: 1, color: AppColors.borderLight),
                            _ProfileInfoTile(
                              icon: Icons.sports_martial_arts,
                              label: 'Belt Level',
                              value: user.beltLevel,
                            ),
                            if (user.bio != null &&
                                user.bio!.isNotEmpty) ...[
                              const Divider(
                                  height: 1, color: AppColors.borderLight),
                              _ProfileInfoTile(
                                icon: Icons.info_outline,
                                label: 'Bio',
                                value: user.bio!,
                                multiline: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stats
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Account Details',
                                style: AppText.h3.copyWith(
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _StatChip(
                                  label: 'Locations',
                                  value: '${user.locationIds.length}',
                                  color: AppColors.info,
                                ),
                                const SizedBox(width: 10),
                                _StatChip(
                                  label: 'Classes',
                                  value: '${user.masterClassIds.length}',
                                  color: AppColors.success,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: AppColors.textHint),
                                const SizedBox(width: 8),
                                Text(
                                  'Member since ${_formatDate(user.createdAt)}',
                                  style: AppText.caption
                                      .copyWith(color: AppColors.textHint),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _ProfileAvatar({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 3,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildPlaceholder(),
                errorWidget: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppText.display.copyWith(
            color: AppColors.primary,
            fontSize: 40,
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        AppText.caption.copyWith(color: AppColors.textHint)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppText.bodyMedium
                      .copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppText.h2.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppText.caption.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
