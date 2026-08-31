import 'package:dilsensei/core/monetization/domain/entitlement_resolution.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dashboard DilSensei memakai dua entitlement: produk Google Play menempel ke
/// `premium`, produk Test Store ke `dilsensei_pro`. Keduanya harus membuka Pro.
const _accepted = <String>{'premium', 'dilsensei_pro'};

void main() {
  group('penentuan status premium dari entitlement', () {
    test('entitlement produksi yang aktif membuka premium', () {
      final status = premiumStatusFrom(
        const [
          EntitlementSnapshot(
            id: 'premium',
            isActive: true,
            expiresAt: '2026-12-31T00:00:00Z',
          ),
        ],
        acceptedIds: _accepted,
      );

      expect(status.isPremium, isTrue);
      expect(status.expiresAt, DateTime.utc(2026, 12, 31));
    });

    test('entitlement Test Store yang aktif juga membuka premium', () {
      final warnings = <String>[];

      final status = premiumStatusFrom(
        const [EntitlementSnapshot(id: 'dilsensei_pro', isActive: true)],
        acceptedIds: _accepted,
        onWarning: (message, detail) => warnings.add(message),
      );

      expect(status.isPremium, isTrue);
      expect(
        warnings,
        isEmpty,
        reason: 'keduanya sah, jadi tidak ada yang perlu diperingatkan',
      );
    });

    test('entitlement kedaluwarsa tidak membuka premium', () {
      final status = premiumStatusFrom(
        const [EntitlementSnapshot(id: 'premium', isActive: false)],
        acceptedIds: _accepted,
      );

      expect(status.isPremium, isFalse);
    });

    test('nama entitlement tak dikenal tetap membuka premium dan dicatat', () {
      // Ini bug yang benar-benar terjadi: kode mencari identifier yang tidak
      // ada di dashboard, sehingga pembelian yang sudah ditagih dilaporkan
      // sebagai "langganan belum aktif" dan Restore selalu berkata tidak ada
      // yang bisa dipulihkan.
      final warnings = <String>[];

      final status = premiumStatusFrom(
        const [EntitlementSnapshot(id: 'entitlement_baru', isActive: true)],
        acceptedIds: _accepted,
        onWarning: (message, detail) => warnings.add('$message | $detail'),
      );

      expect(
        status.isPremium,
        isTrue,
        reason: 'pengguna sudah membayar; akses tidak boleh ditahan',
      );
      expect(warnings, hasLength(1));
      expect(warnings.single, contains('entitlement_baru'));
    });

    test('pelanggan tanpa entitlement sama sekali tidak memicu peringatan', () {
      final warnings = <String>[];

      final status = premiumStatusFrom(
        const [],
        acceptedIds: _accepted,
        onWarning: (message, detail) => warnings.add(message),
      );

      expect(status.isPremium, isFalse);
      expect(
        warnings,
        isEmpty,
        reason: 'pengguna gratis adalah keadaan normal, bukan salah konfigurasi',
      );
    });
  });
}
