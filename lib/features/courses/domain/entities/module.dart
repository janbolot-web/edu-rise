import 'package:freezed_annotation/freezed_annotation.dart';

part 'module.freezed.dart';
part 'module.g.dart';

@freezed
abstract class CourseModule with _$CourseModule {
  const factory CourseModule({
    required String id,
    required String title,
    required String description,
    required List<ModuleLesson> lessons,
    required int duration, // в минутах
  }) = _CourseModule;

  factory CourseModule.fromJson(Map<String, dynamic> json) =>
      _$CourseModuleFromJson(json);
}

@freezed
abstract class ModuleLesson with _$ModuleLesson {
  const factory ModuleLesson({
    required String id,
    required String title,
    required int duration, // в минутах
    @Default(false) bool isPreview,
    @Default('') String videoUrl,
    @Default('') String description,
  }) = _ModuleLesson;

  factory ModuleLesson.fromJson(Map<String, dynamic> json) =>
      _$ModuleLessonFromJson(json);
}
