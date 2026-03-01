import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/conversation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_skeleton_loading.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchConversations();
    });
  }

  Future<void> _startStudentChat() async {
    final auth = context.read<AuthProvider>();
    final masterIds = auth.currentUser?.masterIds ?? [];
    if (masterIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No master assigned to you yet.')),
      );
      return;
    }
    final conv =
        await context.read<ChatProvider>().startConversation(masterIds.first);
    if (conv != null && mounted) {
      context.push('/chat/${conv.id}', extra: conv);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final myId = auth.currentUserId ?? '';
    final isMaster = auth.currentUser?.role != 'student';
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isMaster ? 'Messages' : 'Chat'),
      ),
      body: chat.isLoading && chat.conversations.isEmpty
          ? _ConversationsSkeleton()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<ChatProvider>().fetchConversations(),
              child: chat.conversations.isEmpty
                  ? _EmptyState(isMaster: isMaster, onStart: _startStudentChat)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: chat.conversations.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: 72,
                        endIndent: 16,
                        color: AppColors.borderLight,
                      ),
                      itemBuilder: (_, i) => _ConversationTile(
                        conv: chat.conversations[i],
                        myId: myId,
                      ),
                    ),
            ),
      // Student: FAB to start chat if list is empty handled inside _EmptyState
      // But also show FAB if student has no conversation yet
      floatingActionButton:
          !isMaster && chat.conversations.isEmpty && !chat.isLoading
              ? FloatingActionButton.extended(
                  onPressed: _startStudentChat,
                  backgroundColor: AppColors.primary,
                  icon: const Icon(Icons.chat, color: AppColors.onPrimary),
                  label: Text('Start Chat',
                      style:
                          AppText.button.copyWith(color: AppColors.onPrimary)),
                )
              : null,
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conv;
  final String myId;

  const _ConversationTile({required this.conv, required this.myId});

  @override
  Widget build(BuildContext context) {
    final hasUnread = conv.hasUnread(myId);
    final otherName = conv.otherName(myId);
    final initial = conv.otherInitial(myId);
    final preview = conv.lastMessagePreview;
    final time = conv.lastMessageAt;

    return InkWell(
      onTap: () => context.push('/chat/${conv.id}', extra: conv),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: AppText.h3.copyWith(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherName,
                    style: AppText.bodyMedium.copyWith(
                      fontWeight:
                          hasUnread ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (preview != null)
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption.copyWith(
                        color: hasUnread
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight:
                            hasUnread ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time + unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (time != null)
                  Text(
                    _formatTime(time),
                    style: AppText.caption.copyWith(
                      color: hasUnread
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 4),
                if (hasUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day) {
      return DateFormat('h:mm a').format(dt);
    }
    return DateFormat('MMM d').format(dt);
  }
}

class _EmptyState extends StatelessWidget {
  final bool isMaster;
  final VoidCallback onStart;

  const _EmptyState({required this.isMaster, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight,
              ),
              child: const Icon(Icons.chat_bubble_outline,
                  color: AppColors.primary, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              isMaster ? 'No messages yet' : 'No conversations yet',
              style: AppText.h3,
            ),
            const SizedBox(height: 8),
            Text(
              isMaster
                  ? 'Students will appear here once they message you.'
                  : 'Tap the button below to start chatting with your master.',
              style: AppText.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: const [
            AppSkeletonLoading(
                width: 46, height: 46, borderRadius: BorderRadius.all(Radius.circular(23))),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonLoading(height: 13, width: 140),
                  SizedBox(height: 6),
                  AppSkeletonLoading(height: 11, width: 220),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
