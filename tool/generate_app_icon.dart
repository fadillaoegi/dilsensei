// Generator ikon aplikasi DilSensei (Organic Minimalism).
//
// Jalankan: flutter test tool/generate_app_icon.dart
//
// Output:
//   assets/icon/app_icon.png             -> ikon master 1024px (full bleed)
//   assets/icon/app_icon_foreground.png  -> foreground adaptive icon Android
//   assets/icon/app_icon_preview.png     -> pratinjau 256px
//
// Ikon dirender lewat Canvas milik Flutter, jadi tidak butuh tool eksternal.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _background = Color(0xFF2D6A4F); // Deep Forest Green
const _leaf = Color(0xFFD8F3DC); // Soft Leaf Green
const _offWhite = Color(0xFFFCFCFC); // Off-White

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generate DilSensei app icons', () async {
    await _writeIcon(
      path: 'assets/icon/app_icon.png',
      size: 1024,
      withBackground: true,
      contentScale: 0.66,
    );
    await _writeIcon(
      path: 'assets/icon/app_icon_foreground.png',
      size: 1024,
      withBackground: false,
      contentScale: 0.46, // aman terhadap crop adaptive icon Android
    );
    await _writeIcon(
      path: 'assets/icon/app_icon_preview.png',
      size: 256,
      withBackground: true,
      contentScale: 0.66,
    );
  });
}

Future<void> _writeIcon({
  required String path,
  required int size,
  required bool withBackground,
  double contentScale = 1,
}) async {
  final canvasSize = size.toDouble();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasSize, canvasSize));

  _paintIcon(
    canvas,
    canvasSize,
    withBackground: withBackground,
    contentScale: contentScale,
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();

  if (bytes == null) {
    throw StateError('Gagal meng-encode PNG untuk $path');
  }

  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes.buffer.asUint8List());
}

void _paintIcon(
  Canvas canvas,
  double size, {
  required bool withBackground,
  required double contentScale,
}) {
  if (withBackground) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size, size),
      Paint()..color = _background,
    );

    // Lingkaran lembut sebagai kedalaman, menggantikan shadow tebal.
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size * 0.36,
      Paint()..color = _offWhite.withValues(alpha: 0.06),
    );
  }

  canvas.save();
  canvas.translate(size / 2, size / 2);
  canvas.scale(size * contentScale);
  canvas.rotate(-18 * math.pi / 180);
  _paintLeaf(canvas);
  canvas.restore();
}

/// Menggambar daun dalam ruang unit (tinggi total kurang lebih 1.0).
void _paintLeaf(Canvas canvas) {
  final leafPath = Path()
    ..moveTo(0, -0.5)
    ..cubicTo(0.30, -0.30, 0.34, 0.16, 0, 0.5)
    ..cubicTo(-0.34, 0.16, -0.30, -0.30, 0, -0.5)
    ..close();

  canvas.drawPath(leafPath, Paint()..color = _leaf);

  // Tulang daun dikurung di dalam bidang daun supaya siluetnya tetap bersih.
  canvas.save();
  canvas.clipPath(leafPath);

  // Tulang daun utama: satu goresan bersih dari pangkal ke ujung.
  canvas.drawPath(
    Path()
      ..moveTo(0, 0.46)
      ..quadraticBezierTo(0.055, 0.05, 0, -0.44),
    Paint()
      ..color = _background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.042
      ..strokeCap = StrokeCap.round,
  );

  // Tulang daun samping, ritmis seperti pengulangan latihan.
  final sideVeinPaint = Paint()
    ..color = _background.withValues(alpha: 0.8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.026
    ..strokeCap = StrokeCap.round;

  const veinStarts = <double>[0.24, 0.08, -0.08];
  for (final start in veinStarts) {
    final reach = 0.20 - start.abs() * 0.35;
    for (final direction in const <double>[1, -1]) {
      canvas.drawPath(
        Path()
          ..moveTo(direction * 0.012, start)
          ..quadraticBezierTo(
            direction * reach * 0.7,
            start - 0.035,
            direction * reach,
            start - 0.13,
          ),
        sideVeinPaint,
      );
    }
  }

  canvas.restore();
}
