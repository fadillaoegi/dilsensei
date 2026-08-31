import 'package:flutter/foundation.dart';

import 'subscription_models.dart';

/// Satu entitlement seperti dilaporkan store, tanpa tipe milik SDK.
///
/// Dipisahkan supaya aturan penentuan status premium bisa diuji tanpa plugin
/// native: bug entitlement yang salah nama hanya muncul di perangkat, dan itu
/// tempat paling mahal untuk menemukannya.
@immutable
class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.id,
    required this.isActive,
    this.expiresAt,
  });

  final String id;
  final bool isActive;

  /// Tanggal kedaluwarsa dalam format ISO-8601 seperti dikirim store.
  final String? expiresAt;
}

/// Menentukan status premium dari daftar entitlement.
///
/// [acceptedIds] adalah semua identifier yang dianggap membuka premium; cukup
/// satu di antaranya aktif. Bila tidak ada yang cocok padahal ada entitlement
/// lain yang aktif, pengguna **tetap** dianggap premium dan ketidakcocokannya
/// dicatat lewat [onWarning].
///
/// Perilaku terakhir itu disengaja. Salah nama entitlement adalah kesalahan
/// konfigurasi yang sepenuhnya senyap: pengguna sudah dibayar, store bilang
/// aktif, tapi app menutup fitur yang sudah dibeli sambil berkata "langganan
/// belum aktif". Memilih memberi akses lalu berteriak di log jauh lebih baik
/// daripada menahan barang yang sudah dibayar.
PremiumStatus premiumStatusFrom(
  List<EntitlementSnapshot> entitlements, {
  required Set<String> acceptedIds,
  void Function(String message, String detail)? onWarning,
}) {
  final accepted = entitlements
      .where((entitlement) => acceptedIds.contains(entitlement.id))
      .toList(growable: false);

  final activeAccepted = accepted
      .where((entitlement) => entitlement.isActive)
      .firstOrNull;

  if (activeAccepted != null) {
    return PremiumStatus(
      isPremium: true,
      expiresAt: _parseDate(activeAccepted.expiresAt),
    );
  }

  final otherActive = entitlements
      .where(
        (entitlement) =>
            !acceptedIds.contains(entitlement.id) && entitlement.isActive,
      )
      .firstOrNull;

  if (otherActive != null) {
    onWarning?.call(
      'entitlement aktif tidak sesuai konfigurasi',
      'dicari=${acceptedIds.join("|")} ditemukanAktif=${otherActive.id} '
          'terdaftar=${entitlements.map((item) => item.id).join(",")} '
          '— samakan REVENUECAT_ENTITLEMENT dengan identifier di dashboard',
    );

    return PremiumStatus(
      isPremium: true,
      expiresAt: _parseDate(otherActive.expiresAt),
    );
  }

  if (accepted.isEmpty && entitlements.isNotEmpty) {
    onWarning?.call(
      'entitlement yang dicari tidak ada pada pelanggan ini',
      'dicari=${acceptedIds.join("|")} '
          'terdaftar=${entitlements.map((item) => item.id).join(",")}',
    );
  }

  return PremiumStatus(
    isPremium: false,
    expiresAt: _parseDate(accepted.firstOrNull?.expiresAt),
  );
}

DateTime? _parseDate(String? value) =>
    value == null ? null : DateTime.tryParse(value);
