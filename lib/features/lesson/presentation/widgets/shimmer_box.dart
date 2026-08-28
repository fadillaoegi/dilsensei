import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Skeleton berdenyut halus sebagai pengganti spinner default.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    required this.height,
    this.width = double.infinity,
    this.borderRadius = 16,
    super.key,
  });

  final double height;
  final double width;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.45,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// Placeholder Hero Card selama data dimuat.
class HeroCardSkeleton extends StatelessWidget {
  const HeroCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerBox(height: 208, borderRadius: 24);
  }
}

/// Placeholder daftar modul selama data dimuat.
class LessonListSkeleton extends StatelessWidget {
  const LessonListSkeleton({this.itemCount = 3, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(itemCount, (index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: ShimmerBox(height: 78),
        );
      }),
    );
  }
}
