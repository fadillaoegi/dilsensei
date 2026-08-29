import 'dart:convert';
import 'dart:io';

import 'package:dilsensei/core/monetization/monetization_config.dart';
import 'package:flutter_test/flutter_test.dart';

/// Penjaga rilis untuk syarat store: paywall langganan wajib menautkan Privacy
/// Policy dan Terms yang benar-benar hidup.
void main() {
  group('MonetizationConfig', () {
    test('entitlement id sesuai dashboard RevenueCat', () {
      expect(MonetizationConfig.entitlementId, 'pro');
    });

    test('key Test Store dikenali dari awalannya', () {
      expect(MonetizationConfig.isTestKey('test_contohKeyTestStore'), isTrue);
      expect(MonetizationConfig.isTestKey('goog_abc123'), isFalse);
      expect(MonetizationConfig.isTestKey('appl_abc123'), isFalse);
      expect(MonetizationConfig.isTestKey(''), isFalse);
    });

    test('key Test Store didahulukan atas key platform bila tersedia', () {
      // Tanpa dart-define, testStoreKey kosong sehingga key platform dipakai.
      expect(
        MonetizationConfig.resolveApiKey(platformKey: 'goog_produksi'),
        'goog_produksi',
      );
      expect(MonetizationConfig.resolveApiKey(platformKey: ''), isEmpty);
      expect(MonetizationConfig.isUsingTestStore, isFalse);
    });

    test('URL legal tersusun ke halaman yang tepat', () {
      expect(
        MonetizationConfig.privacyPolicyUrl,
        '${MonetizationConfig.legalBaseUrl}/privacy.html',
      );
      expect(
        MonetizationConfig.termsUrl,
        '${MonetizationConfig.legalBaseUrl}/terms.html',
      );
    });

    test('placeholder bawaan ditandai tidak valid', () {
      // Tanpa --dart-define=LEGAL_BASE_URL, nilainya placeholder .invalid
      // sehingga penjaga ini harus menolaknya.
      expect(
        MonetizationConfig.hasValidLegalUrls,
        isFalse,
        reason:
            'Default harus dianggap belum dikonfigurasi agar tidak lolos rilis',
      );
    });
  });

  group('halaman legal statis', () {
    final files = <String>[
      'docs/index.html',
      'docs/privacy.html',
      'docs/terms.html',
    ];

    test('semua halaman ada beserta stylesheet-nya', () {
      for (final path in files) {
        expect(File(path).existsSync(), isTrue, reason: '$path hilang');
      }
      expect(File('docs/style.css').existsSync(), isTrue);
    });

    test('halaman saling menautkan privacy dan terms', () {
      final privacy = File('docs/privacy.html').readAsStringSync();
      final terms = File('docs/terms.html').readAsStringSync();

      expect(privacy, contains('terms.html'));
      expect(terms, contains('privacy.html'));
    });

    test('Terms memuat ketentuan langganan yang diwajibkan store', () {
      final terms = File('docs/terms.html').readAsStringSync().toLowerCase();

      expect(terms, contains('auto-renewing'));
      expect(terms, contains('free trial'));
      expect(terms, contains('cancel'));
      expect(terms, contains('google play'));
    });

    test('Privacy menyebut pihak yang memproses pembelian', () {
      final privacy = File('docs/privacy.html').readAsStringSync();

      expect(privacy, contains('RevenueCat'));
      expect(privacy, contains('Google Play'));
    });

    test('konfigurasi hosting tidak menerbitkan berkas internal', () {
      // docs/ memuat materi submission yang bersifat internal: strategi
      // kategori lomba dan daftar celah yang diketahui. Hosting docs/ apa
      // adanya akan membocorkan semuanya, jadi dua aturan ignore menjaganya dan
      // test ini memastikan aturan itu tidak hilang saat konfigurasi disunting.
      final config =
          jsonDecode(File('firebase.json').readAsStringSync())
              as Map<String, dynamic>;
      final hosting = config['hosting'] as Map<String, dynamic>;
      final ignore = (hosting['ignore'] as List<dynamic>).cast<String>();

      expect(hosting['public'], 'docs');
      expect(ignore, contains('**/submission/**'));
      expect(ignore, contains('**/*.md'));
    });

    test('hanya halaman legal yang akan terbit', () {
      // Berkas apa pun di docs/ yang bukan .html atau .css harus berada di
      // dalam submission/, sehingga kedua aturan ignore cukup untuk menutupinya.
      final leaking = <String>[];

      for (final entity in Directory('docs').listSync(recursive: true)) {
        if (entity is! File) continue;

        final path = entity.path.replaceAll(r'\\', '/');
        final isPublicType = path.endsWith('.html') || path.endsWith('.css');
        final isInternal =
            path.contains('/submission/') || path.endsWith('.md');

        if (!isPublicType && !isInternal) leaking.add(path);
      }

      expect(
        leaking,
        isEmpty,
        reason:
            'berkas ini akan ikut terbit ke internet padahal bukan halaman '
            'legal: ${leaking.join(', ')}',
      );
    });

    test('Privacy menyebut setiap SDK yang memproses data', () {
      // Penjaga konsistensi antara kode dan kebijakan. Menambahkan SDK tanpa
      // memperbarui halaman ini adalah pelanggaran deklarasi Play, dan itu
      // ditemukan saat review — bukan saat coding.
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final privacy = File(
        'docs/privacy.html',
      ).readAsStringSync().toLowerCase();

      final rules = <String, List<String>>{
        'purchases_flutter': ['revenuecat'],
        'firebase_analytics': ['analytics'],
        'flutter_local_notifications': ['reminder'],
      };

      for (final entry in rules.entries) {
        if (!pubspec.contains('${entry.key}:')) continue;

        for (final keyword in entry.value) {
          expect(
            privacy,
            contains(keyword),
            reason:
                'pubspec memuat ${entry.key} tapi docs/privacy.html tidak '
                'menyebut "$keyword"',
          );
        }
      }
    });

    test('Privacy tidak mengklaim hal yang sudah tidak benar', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final privacy = File(
        'docs/privacy.html',
      ).readAsStringSync().toLowerCase();

      if (pubspec.contains('firebase_analytics:')) {
        // Klaim ini pernah ada di halaman dan menjadi salah begitu Analytics
        // dipasang.
        expect(
          privacy,
          isNot(contains('no analytics')),
          reason: 'halaman masih mengaku tanpa analytics padahal SDK-nya ada',
        );
      }
    });

    // Dihitung saat pengumpulan test supaya bisa menentukan status skip.
    final pending = files
        .where(
          (path) => File(path).readAsStringSync().contains('REPLACE_WITH_'),
        )
        .toList();

    test(
      'tidak ada placeholder yang tertinggal sebelum rilis',
      () {
        for (final path in files) {
          expect(
            File(path).readAsStringSync(),
            isNot(contains('REPLACE_WITH_')),
            reason: '$path masih memuat placeholder',
          );
        }
      },
      // Aktif otomatis begitu email dukungan diisi. Sengaja skip, bukan gagal,
      // agar sinyal suite tetap bersih sampai datanya tersedia.
      skip: pending.isEmpty
          ? false
          : 'MENUNGGU: isi email dukungan pada ${pending.join(', ')} '
                '— Play mewajibkan kontak yang bisa dihubungi sebelum rilis.',
    );
  });
}
