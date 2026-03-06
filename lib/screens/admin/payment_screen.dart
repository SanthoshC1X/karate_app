import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_skeleton_loading.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  void _fetch() {
    context.read<PaymentProvider>().fetchMasterOverview(
          year: _selectedYear,
          month: _selectedMonth,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentProvider>();
    final overview = provider.getOverview(_selectedYear, _selectedMonth);
    final paidCount = overview.where((e) => e.payment?.isPaid == true).length;
    final unpaidCount = overview.length - paidCount;

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$_selectedYear',
                      style: AppText.label.copyWith(color: AppColors.primary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more_rounded,
                      size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Month strip ──────────────────────────────────────────────
          _MonthStrip(
            selectedMonth: _selectedMonth,
            onChanged: (m) {
              setState(() => _selectedMonth = m);
              _fetch();
            },
          ),

          // ── Summary row ──────────────────────────────────────────────
          if (!provider.isLoading && overview.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
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
                    '${DateFormat('MMMM').format(DateTime(0, _selectedMonth))} $_selectedYear',
                    style: AppText.s.copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            ),

          // ── Student list ─────────────────────────────────────────────
          Expanded(
            child: provider.isLoading
                ? const _OverviewSkeleton()
                : provider.error != null
                    ? _ErrorState(message: provider.error!, onRetry: _fetch)
                    : overview.isEmpty
                        ? _EmptyState(
                            month: DateFormat('MMMM')
                                .format(DateTime(0, _selectedMonth)),
                            year: _selectedYear,
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () async => _fetch(),
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 20),
                              itemCount: overview.length,
                              itemBuilder: (_, i) {
                                final entry = overview[i];
                                return _StudentPaymentTile(
                                  entry: entry,
                                  onToggle: () => context
                                      .read<PaymentProvider>()
                                      .togglePayment(
                                        studentId: entry.studentId,
                                        year: _selectedYear,
                                        month: _selectedMonth,
                                      ),
                                  onTap: () => context.push(
                                    '/admin/payment/student/${entry.studentId}',
                                    extra: {
                                      'name': entry.studentName,
                                      'year': _selectedYear,
                                    },
                                  ),
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
    showDialog<int>(
      context: context,
      builder: (_) => _YearPickerDialog(
        selectedYear: _selectedYear,
      ),
    ).then((picked) {
      if (picked != null && picked != _selectedYear) {
        setState(() => _selectedYear = picked);
        _fetch();
      }
    });
  }
}

// ── Month strip ────────────────────────────────────────────────────────────────

class _MonthStrip extends StatelessWidget {
  final int selectedMonth;
  final ValueChanged<int> onChanged;

  const _MonthStrip({required this.selectedMonth, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: 12,
        itemBuilder: (_, i) {
          final m = i + 1;
          final selected = m == selectedMonth;
          return GestureDetector(
            onTap: () => onChanged(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                DateFormat('MMM').format(DateTime(0, m)),
                style: AppText.label.copyWith(
                  color: selected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Student tile ───────────────────────────────────────────────────────────────

class _StudentPaymentTile extends StatelessWidget {
  final StudentPaymentOverview entry;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _StudentPaymentTile({
    required this.entry,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = entry.payment?.isPaid ?? false;
    final hasReceipt = entry.payment?.receiptUrl != null;
    final statusColor = isPaid ? AppColors.success : AppColors.error;
    final statusBg = isPaid ? AppColors.successLight : AppColors.errorLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPaid
                ? AppColors.success.withValues(alpha: 0.25)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: entry.profilePictureUrl != null
                  ? NetworkImage(entry.profilePictureUrl!)
                  : null,
              child: entry.profilePictureUrl == null
                  ? Text(
                      entry.studentName.isNotEmpty
                          ? entry.studentName[0].toUpperCase()
                          : '?',
                      style: AppText.label.copyWith(color: AppColors.primary),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.studentName, style: AppText.h3),
                  Text(entry.beltLevel,
                      style: AppText.s.copyWith(color: AppColors.textHint)),
                ],
              ),
            ),
            if (hasReceipt)
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.receipt_long_rounded,
                    size: 18, color: AppColors.textSecondary),
              ),
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
                child: Icon(
                  isPaid ? Icons.check_rounded : Icons.close_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
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

class _OverviewSkeleton extends StatelessWidget {
  const _OverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: 5,
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
            AppSkeletonLoading(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonLoading(width: 140, height: 14),
                  SizedBox(height: 6),
                  AppSkeletonLoading(width: 80, height: 11),
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

class _EmptyState extends StatelessWidget {
  final String month;
  final int year;

  const _EmptyState({required this.month, required this.year});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline_rounded,
              size: 64, color: AppColors.textOnDark30),
          const SizedBox(height: 16),
          Text('No students found',
              style: AppText.m.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text('$month $year',
              style: AppText.s.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message,
              style: AppText.m.copyWith(color: AppColors.error),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ── Year picker dialog ──────────────────────────────────────────────────────

class _YearPickerDialog extends StatelessWidget {
  final int selectedYear;

  const _YearPickerDialog({required this.selectedYear});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().year;
    final years = List.generate(11, (i) => now - 5 + i); // 5 years back, 5 forward

    return Dialog(
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
                  final isSelected = y == selectedYear;
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
    );
  }
}
