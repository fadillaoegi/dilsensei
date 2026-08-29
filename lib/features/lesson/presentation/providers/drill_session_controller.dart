import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/drill_item.dart';
import '../../domain/services/drill_session_engine.dart';
import 'lesson_providers.dart';
import 'progress_controller.dart';

/// Umpan balik terakhir yang perlu ditampilkan UI.
enum DrillFeedback { none, correct, incorrectWillRepeat, incorrectMovedOn }

@immutable
class DrillSessionUiState {
  const DrillSessionUiState({
    required this.session,
    required this.selectedTokens,
    required this.feedback,
    required this.summary,
    required this.feedbackItem,
  });

  factory DrillSessionUiState.initial(List<DrillItem> items) {
    return DrillSessionUiState(
      session: DrillSessionEngine.start(items),
      selectedTokens: const <String>[],
      feedback: DrillFeedback.none,
      summary: null,
      feedbackItem: null,
    );
  }

  final DrillSessionState session;

  /// Potongan kata yang sudah dipilih pengguna, berurutan.
  final List<String> selectedTokens;
  final DrillFeedback feedback;

  /// Terisi hanya setelah sesi tuntas.
  final SessionSummary? summary;

  /// Butir yang sedang dinilai. Dibutuhkan karena antrean sudah maju saat
  /// umpan balik ditampilkan, sehingga [currentItem] bukan lagi butir itu.
  final DrillItem? feedbackItem;

  DrillItem? get currentItem => session.currentItem;

  /// Butir yang harus ditampilkan UI saat ini.
  DrillItem? get displayItem =>
      isShowingFeedback ? feedbackItem ?? currentItem : currentItem;

  bool get isFinished => session.isFinished;

  bool get isShowingFeedback => feedback != DrillFeedback.none;

  bool get canSubmit =>
      !isShowingFeedback &&
      currentItem != null &&
      selectedTokens.length == currentItem!.answerTokens.length;

  DrillSessionUiState copyWith({
    DrillSessionState? session,
    List<String>? selectedTokens,
    DrillFeedback? feedback,
    SessionSummary? summary,
    DrillItem? feedbackItem,
  }) {
    return DrillSessionUiState(
      session: session ?? this.session,
      selectedTokens: selectedTokens ?? this.selectedTokens,
      feedback: feedback ?? this.feedback,
      summary: summary ?? this.summary,
      feedbackItem: feedbackItem ?? this.feedbackItem,
    );
  }
}

class DrillSessionController extends StateNotifier<DrillSessionUiState> {
  DrillSessionController(this._items)
    : super(DrillSessionUiState.initial(_items)) {
    _stopwatch.start();
  }

  /// Seluruh butir modul, dipakai saat menyusun ulang sesi dari pola lemah.
  final List<DrillItem> _items;

  final Stopwatch _stopwatch = Stopwatch();

  /// Butir mana saja yang menguji salah satu dari [patternIds].
  List<DrillItem> itemsForPatterns(Set<String> patternIds) {
    return _items
        .where((item) => item.patternIds.any(patternIds.contains))
        .toList(growable: false);
  }

  /// Menyusun sesi baru hanya dari pola yang masih lemah.
  ///
  /// Inilah loop inti produk: kesalahan hari ini menentukan latihan berikutnya.
  void restartWithWeakPatterns() {
    final summary = state.summary;
    if (summary == null || summary.weakPatterns.isEmpty) return;

    final patternIds = summary.weakPatterns
        .map((miss) => miss.patternId)
        .toSet();
    final items = itemsForPatterns(patternIds);
    if (items.isEmpty) return;

    state = DrillSessionUiState.initial(items);
    _stopwatch
      ..reset()
      ..start();
  }

  void selectToken(String token) {
    if (state.isShowingFeedback) return;

    state = state.copyWith(
      selectedTokens: <String>[...state.selectedTokens, token],
    );
  }

  /// Menghapus satu potongan pada posisi [index] dari jawaban tersusun.
  void removeTokenAt(int index) {
    if (state.isShowingFeedback) return;
    if (index < 0 || index >= state.selectedTokens.length) return;

    final tokens = <String>[...state.selectedTokens]..removeAt(index);
    state = state.copyWith(selectedTokens: tokens);
  }

  void clearSelection() {
    if (state.isShowingFeedback) return;
    state = state.copyWith(selectedTokens: const <String>[]);
  }

  /// Menilai jawaban dan menahan state pada mode umpan balik.
  void submit() {
    if (!state.canSubmit) return;

    final evaluatedItem = state.currentItem;
    final result = DrillSessionEngine.submit(
      state.session,
      answerTokens: state.selectedTokens,
      responseTime: _stopwatch.elapsed,
    );

    final feedback = result.isCorrect
        ? DrillFeedback.correct
        : result.willRepeat
        ? DrillFeedback.incorrectWillRepeat
        : DrillFeedback.incorrectMovedOn;

    state = state.copyWith(
      session: result.state,
      feedback: feedback,
      feedbackItem: evaluatedItem,
    );
  }

  /// Lanjut ke butir berikutnya setelah umpan balik dibaca.
  void advance() {
    if (!state.isShowingFeedback) return;

    if (state.session.isFinished) {
      state = state.copyWith(
        feedback: DrillFeedback.none,
        selectedTokens: const <String>[],
        summary: DrillSessionEngine.summarize(state.session),
      );
      return;
    }

    _stopwatch
      ..reset()
      ..start();

    state = state.copyWith(
      feedback: DrillFeedback.none,
      selectedTokens: const <String>[],
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }
}

/// Controller per modul; di-dispose otomatis saat layar sesi ditutup.
///
/// Kuncinya sengaja [String] moduleId, bukan daftar butir, supaya controller
/// tidak dibuat ulang setiap rebuild — list tidak punya kesetaraan nilai.
final drillSessionControllerProvider = StateNotifierProvider.autoDispose
    .family<DrillSessionController, DrillSessionUiState, String>((
      ref,
      moduleId,
    ) {
      final available =
          ref.read(drillItemsProvider(moduleId)).value ?? const <DrillItem>[];

      // Panjang sesi mengikuti target harian pengguna, dibatasi jumlah butir
      // yang benar-benar tersedia pada modul ini.
      final count = ref.read(sessionItemCountProvider);
      final items = available.take(count).toList(growable: false);

      return DrillSessionController(items);
    });
