// Menyiapkan aset ikon dan splash dari satu berkas sumber.
//
// Jalankan: flutter test tool/prepare_app_icon.dart
//
// Sumber boleh JPEG maupun PNG dan tidak harus persegi. Tool ini:
//   1. mendeteksi warna latar dari keempat sudut,
//   2. mencari kotak batas isi gambar (memangkas bidang latar yang kosong),
//   3. menghasilkan aset persegi yang dibutuhkan store dan splash screen.
//
// Output:
//   assets/icon/app_icon.png            master 1024px, latar solid
//   assets/icon/app_icon_foreground.png foreground adaptive icon, transparan
//   assets/icon/splash_logo.png         logo splash, transparan
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _sourcePath = 'assets/icon/iconDilsensei.png';

/// Off-White design system, dipakai bila latar sumber tidak terdeteksi.
const _fallbackBackground = Color(0xFFFCFCFC);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('siapkan aset ikon dan splash dari berkas sumber', () async {
    final bytes = File(_sourcePath).readAsBytesSync();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (pixels == null) throw StateError('gagal membaca piksel sumber');

    final analysis = _analyze(image.width, image.height, pixels);
    stdout.writeln(
      'Sumber ${image.width}x${image.height} | '
      'latar #${analysis.background.toARGB32().toRadixString(16).substring(2)} | '
      'isi ${analysis.content.width.round()}x${analysis.content.height.round()} '
      'pada ${analysis.content.left.round()},${analysis.content.top.round()}',
    );

    // Latar dibuat transparan supaya adaptive icon dan splash bisa memakai
    // warna latar sendiri, bukan kotak putih dari berkas sumber.
    final keyed = await _removeBackground(
      width: image.width,
      height: image.height,
      pixels: pixels,
      background: analysis.background,
    );

    await _write(
      path: 'assets/icon/app_icon.png',
      image: keyed,
      content: analysis.content,
      background: _fallbackBackground,
      contentScale: 0.86,
    );
    await _write(
      path: 'assets/icon/app_icon_foreground.png',
      image: keyed,
      content: analysis.content,
      background: null,
      // Adaptive icon memangkas tepi, jadi isinya dibuat lebih kecil.
      contentScale: 0.60,
    );
    await _write(
      path: 'assets/icon/splash_logo.png',
      image: keyed,
      content: analysis.content,
      background: null,
      contentScale: 0.72,
    );

    // Sudut foreground wajib transparan; kalau tidak, adaptive icon akan
    // menampilkan kotak alih-alih bentuk logonya.
    final foregroundAlpha = await _cornerAlpha(
      'assets/icon/app_icon_foreground.png',
    );
    expect(
      foregroundAlpha,
      0,
      reason: 'sudut foreground harus transparan penuh',
    );

    image.dispose();
    keyed.dispose();

    for (final path in <String>[
      'assets/icon/app_icon.png',
      'assets/icon/app_icon_foreground.png',
      'assets/icon/splash_logo.png',
    ]) {
      expect(File(path).existsSync(), isTrue, reason: path);
      stdout.writeln('OK $path (${File(path).lengthSync()} bytes)');
    }
  });
}

class _Analysis {
  const _Analysis({required this.background, required this.content});

  final Color background;
  final Rect content;
}

/// Mendeteksi warna latar dari sudut, lalu mencari kotak batas isi gambar.
_Analysis _analyze(int width, int height, ByteData pixels) {
  Color at(int x, int y) {
    final offset = (y * width + x) * 4;
    return Color.fromARGB(
      pixels.getUint8(offset + 3),
      pixels.getUint8(offset),
      pixels.getUint8(offset + 1),
      pixels.getUint8(offset + 2),
    );
  }

  final corners = <Color>[
    at(0, 0),
    at(width - 1, 0),
    at(0, height - 1),
    at(width - 1, height - 1),
  ];

  // Latar dianggap terdeteksi hanya bila keempat sudut mirip satu sama lain.
  final isUniform = corners.every((c) => _distance(c, corners.first) < 24);
  final background = isUniform ? corners.first : _fallbackBackground;

  var minX = width, minY = height, maxX = -1, maxY = -1;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final pixel = at(x, y);
      final isBackground =
          pixel.a < 0.05 || (isUniform && _distance(pixel, background) < 32);
      if (isBackground) continue;

      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
  }

  if (maxX < 0 || maxY < 0) {
    return _Analysis(
      background: background,
      content: Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    );
  }

  return _Analysis(
    background: background,
    content: Rect.fromLTRB(
      minX.toDouble(),
      minY.toDouble(),
      (maxX + 1).toDouble(),
      (maxY + 1).toDouble(),
    ),
  );
}

double _distance(Color a, Color b) {
  final dr = ((a.r - b.r) * 255).abs();
  final dg = ((a.g - b.g) * 255).abs();
  final db = ((a.b - b.b) * 255).abs();

  return math.max(dr, math.max(dg, db));
}

/// Mengganti piksel yang mirip [background] menjadi transparan.
///
/// Ambangnya dibuat bergradasi supaya tepi anti-alias logo tidak bergerigi.
Future<ui.Image> _removeBackground({
  required int width,
  required int height,
  required ByteData pixels,
  required Color background,
}) async {
  const softStart = 16.0;
  const softEnd = 56.0;

  final output = Uint8List(width * height * 4);
  final bgR = (background.r * 255).round();
  final bgG = (background.g * 255).round();
  final bgB = (background.b * 255).round();

  for (var i = 0; i < width * height; i++) {
    final offset = i * 4;
    final r = pixels.getUint8(offset);
    final g = pixels.getUint8(offset + 1);
    final b = pixels.getUint8(offset + 2);
    final a = pixels.getUint8(offset + 3);

    final delta = math
        .max((r - bgR).abs(), math.max((g - bgG).abs(), (b - bgB).abs()))
        .toDouble();
    final ratio = ((delta - softStart) / (softEnd - softStart)).clamp(0.0, 1.0);

    output[offset] = r;
    output[offset + 1] = g;
    output[offset + 2] = b;
    output[offset + 3] = (a * ratio).round();
  }

  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    output,
    width,
    height,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );

  return completer.future;
}

/// Alpha piksel sudut kiri atas sebuah PNG, untuk memastikan transparansi.
Future<int> _cornerAlpha(String path) async {
  final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
  final frame = await codec.getNextFrame();
  final data = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
  frame.image.dispose();

  return data?.getUint8(3) ?? -1;
}

/// Menggambar [content] dari [image] ke kanvas persegi, terpusat dan proporsional.
Future<void> _write({
  required String path,
  required ui.Image image,
  required Rect content,
  required Color? background,
  required double contentScale,
  int size = 1024,
}) async {
  final canvasSize = size.toDouble();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasSize, canvasSize));

  if (background != null) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasSize, canvasSize),
      Paint()..color = background,
    );
  }

  final box = canvasSize * contentScale;
  final scale = math.min(box / content.width, box / content.height);
  final drawWidth = content.width * scale;
  final drawHeight = content.height * scale;

  canvas.drawImageRect(
    image,
    content,
    Rect.fromLTWH(
      (canvasSize - drawWidth) / 2,
      (canvasSize - drawHeight) / 2,
      drawWidth,
      drawHeight,
    ),
    Paint()..filterQuality = FilterQuality.high,
  );

  final picture = recorder.endRecording();
  final rendered = await picture.toImage(size, size);
  final png = await rendered.toByteData(format: ui.ImageByteFormat.png);
  rendered.dispose();
  picture.dispose();

  if (png == null) throw StateError('gagal meng-encode $path');

  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(png.buffer.asUint8List());
}
