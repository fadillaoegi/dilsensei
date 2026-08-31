import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Batas karakter Google Play Console.
const _titleLimit = 30;
const _shortLimit = 80;
const _fullLimit = 4000;

/// Mengambil isi blok kode yang mengikuti sebuah judul tebal.
///
/// Materi listing disimpan sebagai Markdown supaya bisa disalin langsung ke Play
/// Console. Test membacanya dari sumber yang sama agar angka yang diverifikasi
/// adalah teks yang benar-benar akan ditempel.
String _blockAfter(String markdown, String boldLabel) {
  final labelIndex = markdown.indexOf('**$boldLabel**');
  expect(
    labelIndex,
    isNot(-1),
    reason: 'tidak menemukan label "$boldLabel" di play-listing.md',
  );

  final fenceStart = markdown.indexOf('```', labelIndex);
  expect(
    fenceStart,
    isNot(-1),
    reason: 'tidak ada blok kode setelah $boldLabel',
  );

  final contentStart = markdown.indexOf('\n', fenceStart) + 1;
  final fenceEnd = markdown.indexOf('```', contentStart);
  expect(fenceEnd, isNot(-1), reason: 'blok kode $boldLabel tidak ditutup');

  return markdown.substring(contentStart, fenceEnd).trim();
}

void main() {
  final markdown = File('docs/submission/play-listing.md').readAsStringSync();

  group('batas karakter Play', () {
    final entries = <String, int>{
      'App name': _titleLimit,
      'Short description': _shortLimit,
      'Full description': _fullLimit,
      'Nama app': _titleLimit,
      'Deskripsi singkat': _shortLimit,
      'Deskripsi lengkap': _fullLimit,
    };

    for (final entry in entries.entries) {
      test('${entry.key} tidak melewati ${entry.value} karakter', () {
        final text = _blockAfter(markdown, entry.key);

        expect(
          text.length,
          lessThanOrEqualTo(entry.value),
          reason:
              '${entry.key} panjangnya ${text.length} karakter, '
              'melewati batas ${entry.value}',
        );
        expect(text, isNotEmpty);
      });
    }
  });

  group('aturan isi listing', () {
    Map<String, String> descriptionsOf() => <String, String>{
      'Inggris': _blockAfter(markdown, 'Full description'),
      'Indonesia': _blockAfter(markdown, 'Deskripsi lengkap'),
    };

    test('tidak mengklaim Training Record sebagai kualifikasi', () {
      // Klaim semacam ini menyesatkan calon pekerja migran dan melanggar
      // kebijakan Play soal pernyataan yang menyesatkan.
      final forbidden = <String>[
        'official certificate',
        'certified by',
        'guarantees a job',
        'sertifikat resmi',
        'dijamin lulus',
        'menjamin kerja',
        'setara jlpt',
        'setara jft',
        'equivalent to jlpt',
        'equivalent to jft',
      ];

      for (final entry in descriptionsOf().entries) {
        final text = entry.value.toLowerCase();

        for (final claim in forbidden) {
          expect(
            text,
            isNot(contains(claim)),
            reason: 'deskripsi ${entry.key} memuat klaim terlarang "$claim"',
          );
        }
      }
    });

    test('menyatakan secara eksplisit bahwa ini bukan kualifikasi', () {
      final descriptions = descriptionsOf();

      expect(
        descriptions['Inggris']!.toLowerCase(),
        contains('not a language qualification'),
      );
      expect(
        descriptions['Indonesia']!.toLowerCase(),
        contains('bukan kualifikasi bahasa'),
      );
    });

    test('mencantumkan penafian afiliasi dengan penyelenggara ujian', () {
      // Menyebut nama ujian tanpa penafian bisa dibaca sebagai klaim dukungan.
      final descriptions = descriptionsOf();

      expect(
        descriptions['Inggris']!.toLowerCase(),
        contains('not affiliated'),
      );
      expect(
        descriptions['Indonesia']!.toLowerCase(),
        contains('tidak berafiliasi'),
      );
    });

    test('tidak memakai kata gratis pada judul app', () {
      // Play melarang kata promosi pada judul.
      for (final label in <String>['App name', 'Nama app']) {
        final title = _blockAfter(markdown, label).toLowerCase();

        expect(title, isNot(contains('free')));
        expect(title, isNot(contains('gratis')));
        expect(title, isNot(contains('#1')));
        expect(title, isNot(contains('best')));
      }
    });

    test('kedua bahasa menjelaskan fitur yang sama', () {
      // Listing yang tidak sepadan membuat salah satu bahasa terasa versi lebih
      // rendah, dan itu justru bahasa pengguna sasaran kita.
      final pairs = <String, List<String>>{
        'weak-spot map': ['peta kelemahan'],
        'training record': ['training record'],
        'hiragana': ['hiragana'],
        'katakana': ['katakana'],
        'offline': ['tanpa koneksi'],
        'dark themes': ['tema terang dan gelap'],
      };

      final descriptions = descriptionsOf();
      final english = descriptions['Inggris']!.toLowerCase();
      final indonesian = descriptions['Indonesia']!.toLowerCase();

      for (final entry in pairs.entries) {
        expect(
          english,
          contains(entry.key),
          reason: 'deskripsi Inggris tidak menyebut "${entry.key}"',
        );
        for (final counterpart in entry.value) {
          expect(
            indonesian,
            contains(counterpart),
            reason: 'deskripsi Indonesia tidak menyebut "$counterpart"',
          );
        }
      }
    });
  });
}
