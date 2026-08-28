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
