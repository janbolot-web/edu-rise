// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CourseModule _$CourseModuleFromJson(Map<String, dynamic> json) =>
    _CourseModule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => ModuleLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$CourseModuleToJson(_CourseModule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'lessons': instance.lessons.map((e) => e.toJson()).toList(),
      'duration': instance.duration,
    };

_ModuleLesson _$ModuleLessonFromJson(Map<String, dynamic> json) =>
    _ModuleLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      duration: (json['duration'] as num).toInt(),
      isPreview: json['isPreview'] as bool? ?? false,
      videoUrl: json['videoUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$ModuleLessonToJson(_ModuleLesson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'duration': instance.duration,
      'isPreview': instance.isPreview,
      'videoUrl': instance.videoUrl,
      'description': instance.description,
    };
