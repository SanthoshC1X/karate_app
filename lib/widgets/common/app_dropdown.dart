import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';


class AppDropdown<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? itemLabel;
  final Widget Function(T)? avatarBuilder;
  final bool initiallyExpanded;
  final double? maxMenuHeight;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.itemLabel,
    this.avatarBuilder,
    this.initiallyExpanded = false,
    this.maxMenuHeight,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  late bool _expanded;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _label(T item) =>
      widget.itemLabel?.call(item) ?? item.toString();

  @override
  Widget build(BuildContext context) {
    final selectedText = widget.value == null
        ? (widget.hint ?? '')
        : _label(widget.value as T);

    final maxHeight = widget.maxMenuHeight ??
        (MediaQuery.sizeOf(context).height * 0.34).clamp(180.0, 320.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppText.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
        ],

        // ── Trigger ──────────────────────────────────────────────────────
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _expanded ? AppColors.primary : AppColors.borderInput,
                width: _expanded ? 1.5 : 1.2,
              ),
            ),
            child: Row(
              children: [
                if (widget.value != null && widget.avatarBuilder != null) ...[
                  widget.avatarBuilder!(widget.value as T),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    selectedText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyMedium.copyWith(
                      color: widget.value == null
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Menu ─────────────────────────────────────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 160),
          crossFadeState: _expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: widget.items.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.borderLight,
                ),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = widget.value == item;
                  final label = _label(item);

                  return InkWell(
                    onTap: () {
                      widget.onChanged?.call(item);
                      setState(() => _expanded = false);
                    },
                    child: Container(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.06)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          // Optional avatar
                          if (widget.avatarBuilder != null) ...[
                            widget.avatarBuilder!(item),
                            const SizedBox(width: 12),
                          ] else ...[
                            _InitialAvatar(label: label, selected: isSelected),
                            const SizedBox(width: 12),
                          ],
                          // Label
                          Expanded(
                            child: Text(
                              label,
                              style: AppText.bodyMedium.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          // Checkbox
                          Icon(
                            isSelected
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            size: 20,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String label;
  final bool selected;

  const _InitialAvatar({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final initial = label.isNotEmpty ? label[0].toUpperCase() : '?';
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.surfaceTint,
      ),
      child: Center(
        child: Text(
          initial,
          style: AppText.label.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
