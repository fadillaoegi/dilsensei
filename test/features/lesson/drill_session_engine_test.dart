import 'package:dilsensei/features/lesson/domain/entities/drill_item.dart';
import 'package:dilsensei/features/lesson/domain/entities/grammar_pattern.dart';
import 'package:dilsensei/features/lesson/domain/services/drill_session_engine.dart';
import 'package:flutter_test/flutter_test.dart';

DrillItem _item(String id, {List<String>? patterns}) {
  return DrillItem(
    id: id,
    moduleId: 'module-1',
    prompt: 'Saya pergi ke sekolah.',
    answerTokens: const ['わたし', 'は', 'がっこう', 'に', 'いきます'],
    distractorTokens: const ['を', 'で'],
    patternIds: patterns ?? const ['particle_place'],
  );
}

const _correct = ['わたし', 'は', 'がっこう', 'に', 'いきます'];
const _wrong = ['わたし', 'は', 'がっこう', 'を', 'いきます'];

void main() {
  group('DrillSessionEngine', () {
    test('mulai sesi menempatkan butir pertama sebagai butir aktif', () {
      final state = DrillSessionEngine.start([_item('a'), _item('b')]);

      expect(state.currentItem?.id, 'a');
      expect(state.plannedCount, 2);
      expect(state.isFinished, isFalse);
      expect(state.progress, 0);
    });

    test('jawaban benar menuntaskan butir dan memajukan antrean', () {
      final state = DrillSessionEngine.start([_item('a'), _item('b')]);

      final result = DrillSessionEngine.submit(
        state,
        answerTokens: _correct,
        responseTime: const Duration(seconds: 3),
      );

      expect(result.isCorrect, isTrue);
      expect(result.willRepeat, isFalse);
      expect(result.state.currentItem?.id, 'b');
      expect(result.state.resolvedCount, 1);
    });

    test('jawaban salah mengembalikan butir ke akhir antrean', () {
      final state = DrillSessionEngine.start([_item('a'), _item('b')]);

      final result = DrillSessionEngine.submit(
        state,
        answerTokens: _wrong,
        responseTime: const Duration(seconds: 5),
      );

      expect(result.isCorrect, isFalse);
      expect(result.willRepeat, isTrue);
      expect(result.missedPatternIds, ['particle_place']);
      expect(result.state.currentItem?.id, 'b');
      expect(result.state.queue.last.id, 'a');
      expect(result.state.resolvedCount, 0);
    });

    test('butir dilepas setelah kesempatan mengulang habis', () {
      var state = DrillSessionEngine.start([_item('a')]);

      for (var i = 0; i < DrillSessionEngine.maxRetriesPerItem + 1; i++) {
        expect(state.isFinished, isFalse);
        state = DrillSessionEngine.submit(
          state,
          answerTokens: _wrong,
          responseTime: const Duration(seconds: 6),
        ).state;
      }

      expect(state.isFinished, isTrue);
      expect(state.attempts.length, DrillSessionEngine.maxRetriesPerItem + 1);
    });

    test('hanya percobaan pertama yang ditandai isFirstTry', () {
      var state = DrillSessionEngine.start([_item('a')]);

      state = DrillSessionEngine.submit(
        state,
        answerTokens: _wrong,
        responseTime: const Duration(seconds: 5),
      ).state;
      state = DrillSessionEngine.submit(
        state,
        answerTokens: _correct,
        responseTime: const Duration(seconds: 2),
      ).state;

      expect(state.attempts.first.isFirstTry, isTrue);
      expect(state.attempts.last.isFirstTry, isFalse);
      expect(state.isFinished, isTrue);
    });

    test('ringkasan menghitung akurasi, median, dan pola terlemah', () {
      var state = DrillSessionEngine.start([
        _item('a', patterns: const ['particle_place']),
        _item('b', patterns: const ['particle_place', 'polite_form']),
      ]);

      // Butir a benar pada percobaan pertama (2 detik).
      state = DrillSessionEngine.submit(
        state,
        answerTokens: _correct,
        responseTime: const Duration(seconds: 2),
      ).state;

      // Butir b salah dulu, lalu benar (4 detik).
      state = DrillSessionEngine.submit(
        state,
        answerTokens: _wrong,
        responseTime: const Duration(seconds: 7),
      ).state;
      state = DrillSessionEngine.submit(
        state,
        answerTokens: _correct,
        responseTime: const Duration(seconds: 4),
      ).state;

      final summary = DrillSessionEngine.summarize(state);

      expect(summary.plannedCount, 2);
      expect(summary.firstTryCorrect, 1);
      expect(summary.totalAttempts, 3);
      expect(summary.accuracy, 0.5);
      expect(summary.medianResponseTime, const Duration(seconds: 3));
      expect(summary.weakPatterns.first.patternId, 'particle_place');
      expect(summary.weakPatterns.length, 2);
      expect(GrammarPatterns.labelOf('particle_place'), 'Partikel tempat');
    });

    test('sesi sempurna dan cepat mendekati skor refleks maksimal', () {
      var state = DrillSessionEngine.start([_item('a'), _item('b')]);

      for (var i = 0; i < 2; i++) {
        state = DrillSessionEngine.submit(
          state,
          answerTokens: _correct,
          responseTime: const Duration(seconds: 2),
        ).state;
      }

      expect(DrillSessionEngine.summarize(state).reflexScore, 100);
    });

    test('benar tapi lambat tetap menurunkan skor refleks', () {
      var state = DrillSessionEngine.start([_item('a')]);

      state = DrillSessionEngine.submit(
        state,
        answerTokens: _correct,
        responseTime: const Duration(seconds: 12),
      ).state;

      final summary = DrillSessionEngine.summarize(state);
      expect(summary.accuracy, 1);
      expect(summary.reflexScore, lessThan(85));
    });
  });
}
