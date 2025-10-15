import 'package:freezed_annotation/freezed_annotation.dart';

part 'educational_material.freezed.dart';
part 'educational_material.g.dart';

@freezed
abstract class EducationalMaterial with _$EducationalMaterial {
  const factory EducationalMaterial({
    required String id,
    required String title,
    required String description,
    required String authorId,
    required String authorName,
    required String authorAvatar,
    required MaterialType type,
    required String subject,
    required String grade,
    required double price,
    required String currency,
    required String thumbnailUrl,
    required List<String> fileUrls,
    required int downloads,
    required double rating,
    required int reviewCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isPublished,
    required List<String> tags,
    required String language,
    required int fileSize,
    required String fileFormat,
    required MaterialDifficulty difficulty,
    required int estimatedTime, // в минутах
    required String previewText,
    required List<String> learningObjectives,
    required bool isFree,
    required bool isFeatured,
    required int viewCount,
    @Default(ModerationStatus.pending) ModerationStatus moderationStatus,
    String? moderationComment,
    String? moderatedBy,
    DateTime? moderatedAt,
  }) = _EducationalMaterial;

  factory EducationalMaterial.fromJson(Map<String, dynamic> json) =>
      _$EducationalMaterialFromJson(json);
}

enum MaterialType {
  @JsonValue('presentation')
  presentation,
  @JsonValue('test')
  test,
  @JsonValue('notes')
  notes,
  @JsonValue('worksheet')
  worksheet,
  @JsonValue('lesson_plan')
  lessonPlan,
  @JsonValue('video')
  video,
  @JsonValue('audio')
  audio,
  @JsonValue('interactive')
  interactive,
}

enum MaterialDifficulty {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
}

enum ModerationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
}
