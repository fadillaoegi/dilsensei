import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pilihan tampilan yang tersedia bagi pengguna.
enum AppThemeMode {
  /// Mengikuti setelan perangkat. Default, karena pengguna yang menyalakan mode
  /// gelap di ponselnya biasanya menginginkannya di semua app.
  system('system'),
  light('light'),
  dark('dark');

  const AppThemeMode(this.code);

  final String code;

  ThemeMode get themeMode => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  static AppThemeMode fromCode(String? code) {
    return AppThemeMode.values.where((mode) => mode.code == code).firstOrNull ??
        defaultMode;
  }

  static const defaultMode = AppThemeMode.system;
}

/// Penyimpanan pilihan tema.
class ThemeModeLocalDataSource {
  const ThemeModeLocalDataSource();

  static const _key = 'dilsensei.theme_mode';

  Future<AppThemeMode> read() async {
    final prefs = await SharedPreferences.getInstance();

    return AppThemeMode.fromCode(prefs.getString(_key));
  }

  Future<void> write(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key, mode.code);
  }
}

final themeModeDataSourceProvider = Provider<ThemeModeLocalDataSource>((ref) {
  return const ThemeModeLocalDataSource();
});

class ThemeModeController extends StateNotifier<AppThemeMode> {
  /// Bila [initial] diisi, pemuatan dari penyimpanan dilewati. Dipakai test
  /// supaya tema tidak berubah di tengah pengujian.
  ThemeModeController({required this.dataSource, AppThemeMode? initial})
    : super(initial ?? AppThemeMode.defaultMode) {
    if (initial == null) _load();
  }

  final ThemeModeLocalDataSource dataSource;

  Future<void> _load() async {
    final stored = await dataSource.read();
    if (!mounted) return;

    state = stored;
  }

  Future<void> select(AppThemeMode mode) async {
    if (state == mode) return;

    state = mode;
    await dataSource.write(mode);
  }
}

final themeModeControllerProvider =
    StateNotifierProvider<ThemeModeController, AppThemeMode>((ref) {
      return ThemeModeController(
        dataSource: ref.watch(themeModeDataSourceProvider),
      );
    });

/// Mode tema aktif untuk MaterialApp.
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeModeControllerProvider).themeMode;
});
