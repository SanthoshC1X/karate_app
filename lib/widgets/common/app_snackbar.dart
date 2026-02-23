import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

enum AppSnackbarType { info, error, pending, success }

class AppSnackbar {
  static OverlayEntry? _activeEntry;

  static void show({
    required BuildContext context,
    required AppSnackbarType type,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onClose,
  }) {
    _activeEntry?.remove();
    _activeEntry = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AppSnackbarWidget(
        type: type,
        title: title,
        message: message,
        duration: duration,
        onClose: () {
          if (entry.mounted) {
            entry.remove();
          }
          if (identical(_activeEntry, entry)) {
            _activeEntry = null;
          }
          onClose?.call();
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }
}

class _AppSnackbarWidget extends StatefulWidget {
  final AppSnackbarType type;
  final String title;
  final String message;
  final Duration duration;
  final VoidCallback onClose;

  const _AppSnackbarWidget({
    required this.type,
    required this.title,
    required this.message,
    required this.duration,
    required this.onClose,
  });

  @override
  State<_AppSnackbarWidget> createState() => _AppSnackbarWidgetState();
}

class _AppSnackbarWidgetState extends State<_AppSnackbarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  late final Animation<double> _fadeAnimation = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  Timer? _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.duration, _closeAnimated);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  IconData get _icon {
    switch (widget.type) {
      case AppSnackbarType.info:
        return Icons.info_outline;
      case AppSnackbarType.error:
        return Icons.error_outline;
      case AppSnackbarType.pending:
        return Icons.hourglass_top;
      case AppSnackbarType.success:
        return Icons.check_circle_outline;
    }
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case AppSnackbarType.info:
        return AppColors.infoLight;
      case AppSnackbarType.error:
        return AppColors.errorLight;
      case AppSnackbarType.pending:
        return AppColors.warningLight;
      case AppSnackbarType.success:
        return AppColors.successLight;
    }
  }

  Color get _foregroundColor {
    switch (widget.type) {
      case AppSnackbarType.info:
        return AppColors.infoDark;
      case AppSnackbarType.error:
        return AppColors.errorDark;
      case AppSnackbarType.pending:
        return AppColors.warningDark;
      case AppSnackbarType.success:
        return AppColors.successDark;
    }
  }

  Future<void> _closeAnimated() async {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    await _controller.reverse();
    if (mounted) {
      widget.onClose();
    }
  }

  void _closeImmediate() {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = _foregroundColor;
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Dismissible(
              key: ValueKey('${widget.title}-${widget.message}'),
              direction: DismissDirection.horizontal,
              onDismissed: (_) => _closeImmediate(),
              background: const SizedBox.shrink(),
              secondaryBackground: const SizedBox.shrink(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: fg.withValues(alpha: 0.18)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.overlayStrong,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_icon, size: 22, color: fg),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: AppText.r.copyWith(
                              fontWeight: FontWeight.w700,
                              color: fg,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.message,
                            style: AppText.m.copyWith(color: fg),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _closeAnimated,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.close, size: 20, color: fg),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
