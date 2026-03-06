import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/payment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_skeleton_loading.dart';

class StudentPaymentScreen extends StatefulWidget {
  const StudentPaymentScreen({super.key});

  @override
  State<StudentPaymentScreen> createState() => _StudentPaymentScreenState();
}

class _StudentPaymentScreenState extends State<StudentPaymentScreen> {
  int _year = DateTime.now().year;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().fetchMyPayments(year: _year);
    });
  }

  void _pickYear() {
    final now = DateTime.now().year;
    final years = List.generate(11, (i) => now - 5 + i);
    showDialog<int>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('Select Year', style: AppText.titleMd),
              ),
              SizedBox(
                height: 300,
                width: 280,
                child: ListView.builder(
                  itemCount: years.length,
                  itemBuilder: (_, i) {
                    final y = years[i];
                    final isSelected = y == _year;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      selected: isSelected,
                      selectedTileColor: AppColors.primaryLight,
                      title: Text(
                        '$y',
                        textAlign: TextAlign.center,
                        style: AppText.m.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, y),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((picked) {
      if (picked != null && picked != _year && mounted) {
        setState(() => _year = picked);
        context.read<PaymentProvider>().fetchMyPayments(year: _year);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentProvider>();
    final entries = provider.myPayments;
    final now = DateTime.now();

    final paidCount = entries.where((e) => e.payment?.isPaid == true).length;
    final unpaidCount = entries.length - paidCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Payment',
            style: AppText.titleMd.copyWith(color: AppColors.textOnDark)),
        actions: [
          GestureDetector(
            onTap: _pickYear,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$_year',
                      style:
                          AppText.label.copyWith(color: AppColors.primary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more_rounded,
                      size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
      body: provider.isLoading && entries.isEmpty
          ? const _PaymentSkeleton()
          : Column(
              children: [
                // ── Summary ──────────────────────────────────────────
                if (entries.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _SummaryChip(
                          label: 'Paid',
                          count: paidCount,
                          color: AppColors.success,
                          bg: AppColors.successLight,
                        ),
                        const SizedBox(width: 8),
                        _SummaryChip(
                          label: 'Unpaid',
                          count: unpaidCount,
                          color: AppColors.error,
                          bg: AppColors.errorLight,
                        ),
                        const Spacer(),
                        Text(
                          '$paidCount / ${entries.length}',
                          style: AppText.h2.copyWith(
                              color: AppColors.textOnDark, fontSize: 18),
                        ),
                        const SizedBox(width: 4),
                        Text('paid',
                            style: AppText.s
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),

                // ── Month list ────────────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => context
                        .read<PaymentProvider>()
                        .fetchMyPayments(year: _year),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: entries.length,
                      itemBuilder: (_, i) {
                        final entry = entries[i];
                        final isCurrent = entry.month == now.month &&
                            entry.year == now.year;
                        return _StudentMonthTile(
                          entry: entry,
                          isCurrent: isCurrent,
                          uploading: _uploading,
                          onUpload: () => _uploadReceipt(entry),
                          onViewReceipt: entry.payment?.receiptUrl != null
                              ? () => _viewReceipt(
                                  context, entry.payment!.receiptUrl!)
                              : null,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _uploadReceipt(PaymentMonthEntry entry) async {
    final picker = ImagePicker();
    final file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final uid = context.read<AuthProvider>().currentUserId ?? 'unknown';
      final path = 'receipts/$uid/${entry.year}-${entry.month}.jpg';
      final bytes = await file.readAsBytes();

      await Supabase.instance.client.storage
          .from('payment-receipts')
          .uploadBinary(
            path,
            bytes,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: true),
          );

      final url = Supabase.instance.client.storage
          .from('payment-receipts')
          .getPublicUrl(path);

      if (!mounted) return;
      await context.read<PaymentProvider>().saveMyReceipt(
            year: entry.year,
            month: entry.month,
            receiptUrl: url,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Receipt uploaded successfully'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Upload failed: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _viewReceipt(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (_, __) => const SizedBox(
                height: 200,
                child: Center(
                    child:
                        CircularProgressIndicator(color: Colors.white))),
            errorWidget: (_, __, ___) => const Padding(
              padding: EdgeInsets.all(32),
              child: Icon(Icons.broken_image, color: Colors.white, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Month tile ─────────────────────────────────────────────────────────────────

class _StudentMonthTile extends StatelessWidget {
  final PaymentMonthEntry entry;
  final bool isCurrent;
  final bool uploading;
  final VoidCallback onUpload;
  final VoidCallback? onViewReceipt;

  const _StudentMonthTile({
    required this.entry,
    required this.isCurrent,
    required this.uploading,
    required this.onUpload,
    this.onViewReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = entry.payment?.isPaid ?? false;
    final hasReceipt = entry.payment?.receiptUrl != null;
    final monthName =
        DateFormat('MMMM').format(DateTime(entry.year, entry.month));
    final statusColor = isPaid ? AppColors.success : AppColors.error;
    final statusBg = isPaid ? AppColors.successLight : AppColors.errorLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? AppColors.primary.withValues(alpha: 0.5)
              : isPaid
                  ? AppColors.success.withValues(alpha: 0.25)
                  : AppColors.border,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Main row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(monthName, style: AppText.h3),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('Current',
                                  style: AppText.label.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${entry.year}',
                          style:
                              AppText.s.copyWith(color: AppColors.textHint)),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: statusBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.4),
                        width: 1.5),
                  ),
                  child: Icon(
                    isPaid ? Icons.check_rounded : Icons.close_rounded,
                    color: statusColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Action bar (view receipt / upload)
          if (hasReceipt || !isPaid)
            Container(
              decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  if (hasReceipt) ...[
                    GestureDetector(
                      onTap: onViewReceipt,
                      child: Row(
                        children: [
                          const Icon(Icons.receipt_long_rounded,
                              size: 15, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Text('View Receipt',
                              style: AppText.label.copyWith(
                                  color: AppColors.primary, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (!isPaid) const SizedBox(width: 16),
                  ],
                  if (!isPaid)
                    GestureDetector(
                      onTap: uploading ? null : onUpload,
                      child: Row(
                        children: [
                          uploading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary),
                                )
                              : const Icon(Icons.upload_rounded,
                                  size: 15, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Text(
                            hasReceipt
                                ? 'Replace Receipt'
                                : 'Upload Receipt',
                            style: AppText.label.copyWith(
                                color: AppColors.primary, fontSize: 12),
                          ),
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

// ── Summary chip ───────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bg;

  const _SummaryChip(
      {required this.label,
      required this.count,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text('$count $label',
              style: AppText.label.copyWith(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Skeleton ───────────────────────────────────────────────────────────────────

class _PaymentSkeleton extends StatelessWidget {
  const _PaymentSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonLoading(width: 100, height: 14),
                  SizedBox(height: 6),
                  AppSkeletonLoading(width: 50, height: 11),
                ],
              ),
            ),
            AppSkeletonLoading(
                width: 42,
                height: 42,
                borderRadius: BorderRadius.all(Radius.circular(21))),
          ],
        ),
      ),
    );
  }
}
