import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../../domain/entities/drill_item.dart';
import '../../domain/entities/lesson_module.dart';
import '../models/drill_item_dto.dart';
import '../models/lesson_module_dto.dart';

/// Data source lokal yang membaca dummy data dari aset JSON.
class LessonLocalDataSource {
  const LessonLocalDataSource({this.bundle});

  static const modulesAssetPath = 'assets/mock/lesson_modules.json';
  static const drillItemsAssetPath = 'assets/mock/drill_items.json';

  /// Dapat di-inject supaya test tidak bergantung pada [rootBundle].
  final AssetBundle? bundle;

  Future<List<LessonModule>> fetchLessonModules() async {
    final decoded = await _decodeList(modulesAssetPath);

    return decoded.map(LessonModuleDto.fromJson).toList(growable: false);
  }

  Future<List<DrillItem>> fetchDrillItems(String moduleId) async {
    final decoded = await _decodeList(drillItemsAssetPath);

    return decoded
        .map(DrillItemDto.fromJson)
        .where((item) => item.moduleId == moduleId)
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _decodeList(String assetPath) async {
    final raw = await (bundle ?? rootBundle).loadString(assetPath);
    return (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  }
}
