import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppSkeletonLoading extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const AppSkeletonLoading({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<AppSkeletonLoading> createState() => _AppSkeletonLoadingState();
}

class _AppSkeletonLoadingState extends State<AppSkeletonLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? AppColors.white5;
    final highlight = widget.highlightColor ?? AppColors.white1;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final slide = (_controller.value * 2) - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(slide - 1, 0),
              end: Alignment(slide + 1, 0),
              colors: [base, highlight, base],
              stops: const [0.2, 0.5, 0.8],
            ),
          ),
        );
      },
    );
  }
}

class AppSkeletonListItem extends StatelessWidget {
  final double height;

  const AppSkeletonListItem({super.key, this.height = 84});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const AppSkeletonLoading(
            width: 44,
            height: 44,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppSkeletonLoading(width: 130, height: 12),
                SizedBox(height: 8),
                AppSkeletonLoading(width: 90, height: 10),
              ],
            ),
          ),
          const AppSkeletonLoading(width: 26, height: 26),
        ],
      ),
    );
  }
}
