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
      note: json['note'] as String?,
    );
  }

  static List<String> _stringList(Object? value) {
    return List<String>.unmodifiable((value as List<dynamic>).cast<String>());
  }
}
