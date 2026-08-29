import '../../domain/entities/drill_item.dart';

/// Mapper JSON drill (snake_case) ke entity domain.
abstract final class DrillItemDto {
  static DrillItem fromJson(Map<String, dynamic> json) {
    return DrillItem(
      id: json['id'] as String,
      moduleId: json['module_id'] as String,
      prompt: json['prompt'] as String,
      answerTokens: _stringList(json['answer_tokens']),
      distractorTokens: _stringList(json['distractor_tokens']),
      patternIds: _stringList(json['pattern_ids']),
      type: _typeFrom(json['type'] as String?),
      questionText: json['question_text'] as String?,
      instruction: json['instruction'] as String?,
      note: json['note'] as String?,
      promptEn: json['prompt_en'] as String?,
      instructionEn: json['instruction_en'] as String?,
      noteEn: json['note_en'] as String?,
    );
  }

  /// Butir tanpa field `type` dianggap menyusun kalimat, supaya konten lama
  /// tetap terbaca tanpa perubahan.
  static DrillType _typeFrom(String? value) => switch (value) {
    'particle' => DrillType.chooseParticle,
    'transform' => DrillType.transformForm,
    _ => DrillType.assembleSentence,
  };

  static List<String> _stringList(Object? value) {
    return List<String>.unmodifiable((value as List<dynamic>).cast<String>());
  }
}
