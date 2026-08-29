// Menghasilkan feature graphic Play Store 1024x500.
//
// Jalankan: flutter test tool/generate_feature_graphic.dart
//
// Font dimuat dari aset proyek lewat FontLoader supaya teksnya benar-benar
// dirender dengan Space Grotesk dan Plus Jakarta Sans, bukan font uji.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _width = 1024;
const _height = 500;

const _background = Color(0xFFFCFCFC);
const _primary = Color(0xFF2D6A4F);
const _secondary = Color(0xFFD8F3DC);
const _textPrimary = Color(0xFF1A1A1A);
const _textSecondary = Color(0xFF666666);

/// Play memangkas sebagian tepi pada beberapa penempatan, jadi seluruh teks
/// dijaga di dalam margin ini.
const _safeMargin = 56.0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('render feature graphic 1024x500', () async {
    await _loadFont('Space Grotesk', 'assets/fonts/SpaceGrotesk-Bold.ttf');
    await _loadFont(
      'Plus Jakarta Sans',
      'assets/fonts/PlusJakartaSans-Regular.ttf',
    );

    final logo = await _loadImage('assets/icon/splash_logo.png');

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, _width.toDouble(), _height.toDouble()),
    );

    _paint(canvas, logo);

    final picture = recorder.endRecording();
    final rendered = await picture.toImage(_width, _height);
    final png = await rendered.toByteData(format: ui.ImageByteFormat.png);
    rendered.dispose();
    picture.dispose();
    logo.dispose();

    if (png == null) throw StateError('gagal meng-encode feature graphic');

    const path = 'assets/store/feature_graphic.png';
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(png.buffer.asUint8List());

    expect(File(path).existsSync(), isTrue);
    stdout.writeln('OK $path (${File(path).lengthSync()} bytes)');
  });
}

void _paint(Canvas canvas, ui.Image logo) {
  canvas.drawRect(
    Rect.fromLTWH(0, 0, _width.toDouble(), _height.toDouble()),
    Paint()..color = _background,
  );

  // Bidang hijau lembut di kanan sebagai kedalaman, tanpa gradien.
  canvas.drawCircle(
    const Offset(_width - 60, _height / 2),
    260,
    Paint()..color = _secondary,
  );

  final logoBox = Rect.fromLTWH(_width - 380, (_height - 300) / 2, 300, 300);
  canvas.drawImageRect(
    logo,
    Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
    logoBox,
    Paint()..filterQuality = FilterQuality.high,
  );

  final textWidth = _width - 380 - _safeMargin * 2 + 40;

  final headline = _painter(
    text: 'Grammar you don’t\nhave to think about',
    style: const TextStyle(
      fontFamily: 'Space Grotesk',
      fontWeight: FontWeight.w700,
      fontSize: 58,
      height: 1.08,
      letterSpacing: -1.5,
      color: _textPrimary,
    ),
    maxWidth: textWidth,
  );

  final subline = _painter(
    text:
        'Short drills that measure how long you hesitate,\n'
        'then rebuild tomorrow from the patterns you miss.',
    style: const TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 24,
      height: 1.5,
      color: _textSecondary,
    ),
    maxWidth: textWidth,
  );

  final badge = _painter(
    text: 'DILSENSEI',
    style: const TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontWeight: FontWeight.w700,
      fontSize: 20,
      letterSpacing: 3,
      color: _primary,
    ),
    maxWidth: textWidth,
  );

  final blockHeight = badge.height + 22 + headline.height + 22 + subline.height;
  var y = (_height - blockHeight) / 2;

  badge.paint(canvas, Offset(_safeMargin, y));
  y += badge.height + 22;
  headline.paint(canvas, Offset(_safeMargin, y));
  y += headline.height + 22;
  subline.paint(canvas, Offset(_safeMargin, y));
}

TextPainter _painter({
  required String text,
  required TextStyle style,
  required double maxWidth,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);

  return painter;
}

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(
      Future<ByteData>.value(File(path).readAsBytesSync().buffer.asByteData()),
    );

  await loader.load();
}

Future<ui.Image> _loadImage(String path) async {
  final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
  final frame = await codec.getNextFrame();

  return frame.image;
}
