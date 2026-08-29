import 'package:dilsensei/features/lesson/data/datasources/lesson_local_data_source.dart';
import 'package:dilsensei/features/lesson/domain/entities/drill_item.dart';
import 'package:dilsensei/features/lesson/domain/entities/grammar_pattern.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test ini membaca aset sungguhan, bukan fixture, karena bug yang paling
/// berbahaya justru ada di data: modul tanpa butir latihan berarti pengguna
/// menekan "Mulai Sesi" lalu menemukan layar kosong.
void main() {
  // rootBundle butuh binding untuk membaca aset.
  TestWidgetsFlutterBinding.ensureInitialized();

  const dataSource = LessonLocalDataSource();
  final knownPatternIds = GrammarPatterns.all.toSet();

  test('setiap modul punya minimal tiga butir latihan', () async {
    final modules = await dataSource.fetchLessonModules();
    expect(modules, isNotEmpty);

    for (final module in modules) {
      final items = await dataSource.fetchDrillItems(module.id);

      expect(
        items.length,
        greaterThanOrEqualTo(3),
        reason:
            'Modul "${module.title}" (${module.id}) hanya punya '
            '${items.length} butir. Sesi akan terasa kosong.',
      );
    }
  });

  test('setiap butir latihan wajar dan polanya dikenal', () async {
    final modules = await dataSource.fetchLessonModules();
    final moduleIds = modules.map((module) => module.id).toSet();
    final seenIds = <String>{};

    for (final module in modules) {
      final items = await dataSource.fetchDrillItems(module.id);

      for (final item in items) {
        expect(
          moduleIds,
          contains(item.moduleId),
          reason: 'module_id "${item.moduleId}" tidak ada di daftar modul',
        );
        expect(
          seenIds.add(item.id),
          isTrue,
          reason: 'id butir "${item.id}" duplikat',
        );

        expect(item.prompt.trim(), isNotEmpty, reason: item.id);
        expect(item.patternIds, isNotEmpty, reason: item.id);
        expect(
          item.distractorTokens,
          isNotEmpty,
          reason: '${item.id} tanpa pengecoh membuat soal terlalu mudah',
        );

        switch (item.type) {
          case DrillType.assembleSentence:
            expect(
              item.answerTokens.length,
              greaterThanOrEqualTo(2),
              reason: '${item.id} terlalu pendek untuk disusun',
            );

          case DrillType.chooseParticle:
            expect(
              item.answerTokens.length,
              1,
              reason: '${item.id} isi partikel harus satu jawaban',
            );
            expect(
              item.questionText,
              contains(DrillItem.blankMarker),
              reason:
                  '${item.id} butuh penanda rumpang ${DrillItem.blankMarker}',
            );
            expect(
              item.distractorTokens.length,
              greaterThanOrEqualTo(2),
              reason: '${item.id} pilihan partikel terlalu sedikit',
            );

          case DrillType.transformForm:
            expect(
              item.answerTokens.length,
              1,
              reason: '${item.id} transformasi harus satu jawaban',
            );
            expect(
              item.questionText?.trim(),
              isNotEmpty,
              reason: '${item.id} butuh bentuk dasar yang diubah',
            );
            expect(
              item.instruction?.trim(),
              isNotEmpty,
              reason: '${item.id} butuh instruksi perubahan bentuk',
            );
        }

        for (final patternId in item.patternIds) {
          expect(
            knownPatternIds,
            contains(patternId),
            reason:
                'pola "$patternId" pada ${item.id} tidak ada di '
                'GrammarPatterns, sehingga peta kelemahan menampilkan id mentah',
          );
        }

        // Pengecoh tidak boleh menduplikasi jawaban, karena chip jawaban dan
        // chip pengecoh akan tampak identik dan menyesatkan.
        for (final distractor in item.distractorTokens) {
          expect(
            item.answerTokens,
            isNot(contains(distractor)),
            reason: '${item.id}: pengecoh "$distractor" sama dengan jawaban',
          );
        }
      }
    }
  });

  test('setiap modul memuat lebih dari satu tipe latihan', () async {
    final modules = await dataSource.fetchLessonModules();

    for (final module in modules) {
      final items = await dataSource.fetchDrillItems(module.id);
      final types = items.map((item) => item.type).toSet();

      expect(
        types.length,
        greaterThanOrEqualTo(2),
        reason:
            'Modul "${module.title}" hanya punya satu tipe latihan, '
            'sesi akan terasa monoton',
      );
      expect(
        types,
        contains(DrillType.assembleSentence),
        reason: 'menyusun kalimat adalah tulang punggung setiap modul',
      );
    }
  });

  test('setiap konten punya terjemahan Inggris', () async {
    final modules = await dataSource.fetchLessonModules();

    for (final module in modules) {
      expect(
        module.titleFor('en'),
        isNot(module.title),
        reason: 'Modul "${module.title}" belum punya title_en',
      );
      expect(
        module.subtitleFor('en'),
        isNot(module.subtitle),
        reason: 'Modul "${module.title}" belum punya subtitle_en',
      );

      for (final item in await dataSource.fetchDrillItems(module.id)) {
        expect(
          item.promptFor('en'),
          isNot(item.prompt),
          reason: '${item.id} belum punya prompt_en',
        );

        if (item.note != null) {
          expect(
            item.noteFor('en'),
            isNot(item.note),
            reason: '${item.id} belum punya note_en',
          );
        }
        if (item.instruction != null) {
          expect(
            item.instructionFor('en'),
            isNot(item.instruction),
            reason: '${item.id} belum punya instruction_en',
          );
        }
      }
    }
  });

  test('modul gratis cukup untuk mengisi satu sesi penuh', () async {
    final modules = await dataSource.fetchLessonModules();
    final freeModules = modules.where((module) => !module.isPremium);

    expect(freeModules, isNotEmpty, reason: 'harus ada konten gratis');

    for (final module in freeModules) {
      final items = await dataSource.fetchDrillItems(module.id);
      expect(
        items.length,
        greaterThanOrEqualTo(6),
        reason: 'Modul gratis "${module.title}" jadi kesan pertama pengguna',
      );
    }
  });
}
