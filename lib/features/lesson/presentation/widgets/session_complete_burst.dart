import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Animasi tamat sesi: centang yang digambar, disertai daun yang melayang naik.
///
/// Motifnya daun, bukan konfeti, supaya tetap sejalan dengan design system.
/// Bila pengguna mengaktifkan "kurangi gerak" di sistem, animasinya dilewati dan
/// yang tampil langsung bentuk akhirnya — bukan dihilangkan, karena tanda tamat
/// tetap perlu terlihat.
class SessionCompleteBurst extends StatefulWidget {
  const SessionCompleteBurst({this.size = 96, super.key});

  final double size;

  @override
  State<SessionCompleteBurst> createState() => _SessionCompleteBurstState();
}

class _SessionCompleteBurstState extends State<SessionCompleteBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  bool _isReducedMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced == _isReducedMotion && _controller.isAnimating) return;

    _isReducedMotion = reduced;
    if (reduced) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _BurstPainter(
            progress: _controller.value,
            palette: context.palette,
          ),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.progress, required this.palette});

  final double progress;

  /// Painter tidak punya BuildContext, jadi palet disuntikkan. Efek sampingnya
  /// bagus: warna animasi ini bisa diuji tanpa membangun widget tree.
  final AppPalette palette;

  /// Jumlah daun yang melayang; sedikit saja agar tidak berisik.
  static const _leafCount = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.34;

    _paintLeaves(canvas, center, size);

    // Lingkaran latar tumbuh lebih dulu, lalu centang digambar.
    final circleProgress = Curves.easeOutBack.transform(
      progress.clamp(0.0, 0.55) / 0.55,
    );
    canvas.drawCircle(
      center,
      radius * circleProgress,
      Paint()..color = palette.surfaceAccent,
    );

    if (progress < 0.35) return;

    final checkProgress = Curves.easeOutCubic.transform(
      ((progress - 0.35) / 0.45).clamp(0.0, 1.0),
    );
    _paintCheck(canvas, center, radius, checkProgress);
  }

  void _paintLeaves(Canvas canvas, Offset center, Size size) {
    if (progress < 0.2) return;

    final leafProgress = ((progress - 0.2) / 0.8).clamp(0.0, 1.0);
    final paint = Paint()..color = palette.primary.withValues(alpha: 0.35);

    for (var i = 0; i < _leafCount; i++) {
      // Sudut disebar tetap agar hasilnya sama tiap kali, bukan acak.
      final angle = (i / _leafCount) * 2 * math.pi - math.pi / 2;
      final distance =
          size.width * 0.52 * Curves.easeOut.transform(leafProgress);
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      final fade = (1 - leafProgress).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(angle + math.pi / 2);
      canvas.drawPath(
        _leafPath(size.width * 0.11 * fade),
        paint..color = palette.primary.withValues(alpha: 0.35 * fade),
      );
      canvas.restore();
    }
  }

  Path _leafPath(double length) {
    if (length <= 0) return Path();

    return Path()
      ..moveTo(0, -length)
      ..cubicTo(
        length * 0.6,
        -length * 0.6,
        length * 0.68,
        length * 0.32,
        0,
        length,
      )
      ..cubicTo(
        -length * 0.68,
        length * 0.32,
        -length * 0.6,
        -length * 0.6,
        0,
        -length,
      )
      ..close();
  }

  void _paintCheck(
    Canvas canvas,
    Offset center,
    double radius,
    double checkProgress,
  ) {
    final start = center + Offset(-radius * 0.42, radius * 0.04);
    final middle = center + Offset(-radius * 0.1, radius * 0.36);
    final end = center + Offset(radius * 0.46, -radius * 0.34);

    final paint = Paint()
      ..color = palette.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Dua segmen digambar berurutan supaya terasa seperti goresan tangan.
    const firstShare = 0.4;
    if (checkProgress <= firstShare) {
      final t = checkProgress / firstShare;
      canvas.drawLine(start, Offset.lerp(start, middle, t)!, paint);
      return;
    }

    final t = ((checkProgress - firstShare) / (1 - firstShare)).clamp(0.0, 1.0);
    canvas.drawPath(
      Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(middle.dx, middle.dy)
        ..lineTo(
          Offset.lerp(middle, end, t)!.dx,
          Offset.lerp(middle, end, t)!.dy,
        ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}
