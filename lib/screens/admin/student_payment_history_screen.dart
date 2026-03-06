import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_skeleton_loading.dart';

class StudentPaymentHistoryScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final int initialYear;

  const StudentPaymentHistoryScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.initialYear,
  });

  @override
  State<StudentPaymentHistoryScreen> createState() =>
      _StudentPaymentHistoryScreenState();
}

class _StudentPaymentHistoryScreenState
    extends State<StudentPaymentHistoryScreen> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  void _fetch() {
    context.read<PaymentProvider>().fetchStudentYearHistory(
          studentId: widget.studentId,
          year: _year,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentProvider>();
    final history = provider.getStudentHistory(widget.studentId);
    final now = DateTime.now();

    final paidCount =
        history.where((e) => e.payment?.isPaid == true).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.studentName,
                style: AppText.titleMd.copyWith(color: AppColors.textOnDark)),
            Text('Payment History',
                style: AppText.s.copyWith(color: AppColors.textSecondary)),
          ],
        ),
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
      body: provider.isLoading
          ? const _HistorySkeleton()
          : Column(
              children: [
                // ── Year summary ───────────────────────────────────────
                if (history.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _YearStatBox(
                          label: 'Paid',
                          value: '$paidCount',
                          color: AppColors.success,
                          bg: AppColors.successLight,
                        ),
                        const SizedBox(width: 12),
                        _YearStatBox(
                          label: 'Unpaid',
                          value: '${history.length - paidCount}',
                          color: AppColors.error,
                          bg: AppColors.errorLight,
                        ),
                        const Spacer(),
                        Text(
                          '$paidCount / ${history.length}',
                          style: AppText.h2.copyWith(
                              color: AppColors.textOnDark, fontSize: 20),
                        ),
                        const SizedBox(width: 4),
                        Text('months paid',
                            style: AppText.s
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),

                // ── Month rows ─────────────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => _fetch(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: history.length,
                      itemBuilder: (_, i) {
                        final entry = history[i];
                        final isFuture = _year > now.year ||
                            (_year == now.year && entry.month > now.month);
                        return _MonthHistoryTile(
                          entry: entry,
                          isFuture: isFuture,
                          onToggle: isFuture
                              ? null
                              : () => context
                                  .read<PaymentProvider>()
                                  .togglePayment(
                                    studentId: widget.studentId,
                                    year: _year,
                                    month: entry.month,
                                  ),
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
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
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
      if (picked != null && picked != _year) {
        setState(() => _year = picked);
        _fetch();
      }
    });
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
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
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

class _MonthHistoryTile extends StatelessWidget {
  final PaymentMonthEntry entry;
  final bool isFuture;
  final VoidCallback? onToggle;
  final VoidCallback? onViewReceipt;

  const _MonthHistoryTile({
    required this.entry,
    required this.isFuture,
    this.onToggle,
    this.onViewReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = entry.payment?.isPaid ?? false;
    final hasReceipt = entry.payment?.receiptUrl != null;
    final monthName =
        DateFormat('MMMM').format(DateTime(entry.year, entry.month));

    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    if (isFuture) {
      statusColor = AppColors.textHint;
      statusBg = AppColors.surfaceTint;
      statusIcon = Icons.remove_rounded;
    } else if (isPaid) {
      statusColor = AppColors.success;
      statusBg = AppColors.successLight;
      statusIcon = Icons.check_rounded;
    } else {
      statusColor = AppColors.error;
      statusBg = AppColors.errorLight;
      statusIcon = Icons.close_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isFuture ? AppColors.surfaceTint : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPaid && !isFuture
              ? AppColors.success.withValues(alpha: 0.25)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          // Month name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthName,
                  style: AppText.h3.copyWith(
                    color: isFuture
                        ? AppColors.textHint
                        : AppColors.textOnDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.year}',
                  style: AppText.s.copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),

          // Receipt button
          if (hasReceipt && !isFuture)
            GestureDetector(
              onTap: onViewReceipt,
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_long_rounded,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Receipt',
                        style: AppText.label.copyWith(
                            color: AppColors.primary, fontSize: 11)),
                  ],
                ),
              ),
            ),

          // Status badge
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: statusBg,
                shape: BoxShape.circle,
                border: Border.all(
                    color: statusColor.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Year stat box ──────────────────────────────────────────────────────────────

class _YearStatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _YearStatBox(
      {required this.label,
      required this.value,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          const SizedBox(width: 6),
          Text('$value $label',
              style: AppText.label.copyWith(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Skeleton ───────────────────────────────────────────────────────────────────

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: 8,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
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
                  AppSkeletonLoading(width: 90, height: 14),
                  SizedBox(height: 6),
                  AppSkeletonLoading(width: 40, height: 11),
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
