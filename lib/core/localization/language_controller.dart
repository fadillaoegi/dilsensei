import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';

/// Bahasa operasi aplikasi.
enum AppLanguage {
  english('en'),
  indonesian('id');

  const AppLanguage(this.code);

  final String code;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values
            .where((language) => language.code == code)
            .firstOrNull ??
        defaultLanguage;
  }

  /// Bahasa Inggris menjadi default karena app ini menyasar pengguna global.
  static const defaultLanguage = AppLanguage.english;
}

/// Penyimpanan pilihan bahasa.
class LanguageLocalDataSource {
  const LanguageLocalDataSource();

  static const _key = 'dilsensei.language_code';

  Future<AppLanguage> read() async {
    final prefs = await SharedPreferences.getInstance();

    return AppLanguage.fromCode(prefs.getString(_key));
  }

  Future<void> write(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key, language.code);
  }
}

final languageDataSourceProvider = Provider<LanguageLocalDataSource>((ref) {
  return const LanguageLocalDataSource();
});

class LanguageController extends StateNotifier<AppLanguage> {
  /// Bila [initial] diisi, pemuatan dari penyimpanan dilewati. Dipakai test
  /// supaya locale tidak berubah di tengah pengujian.
  LanguageController({required this.dataSource, AppLanguage? initial})
    : super(initial ?? AppLanguage.defaultLanguage) {
    if (initial == null) _load();
  }

  final LanguageLocalDataSource dataSource;

  Future<void> _load() async {
    final stored = await dataSource.read();
    if (!mounted) return;

    state = stored;
  }

  Future<void> select(AppLanguage language) async {
    if (state == language) return;

    state = language;
    await dataSource.write(language);
  }
}

final languageControllerProvider =
    StateNotifierProvider<LanguageController, AppLanguage>((ref) {
      return LanguageController(
        dataSource: ref.watch(languageDataSourceProvider),
      );
    });

/// Locale aktif untuk MaterialApp.
final localeProvider = Provider<Locale>((ref) {
  return ref.watch(languageControllerProvider).locale;
});

/// Daftar locale yang benar-benar didukung berkas ARB.
List<Locale> get supportedLocales => AppL10n.supportedLocales;
