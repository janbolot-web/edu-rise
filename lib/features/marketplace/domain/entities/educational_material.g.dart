// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'educational_material.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EducationalMaterial _$EducationalMaterialFromJson(Map<String, dynamic> json) =>
    _EducationalMaterial(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatar: json['authorAvatar'] as String,
      type: $enumDecode(_$MaterialTypeEnumMap, json['type']),
      subject: json['subject'] as String,
      grade: json['grade'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      fileUrls: (json['fileUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      downloads: (json['downloads'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPublished: json['isPublished'] as bool,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      language: json['language'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      fileFormat: json['fileFormat'] as String,
      difficulty: $enumDecode(_$MaterialDifficultyEnumMap, json['difficulty']),
      estimatedTime: (json['estimatedTime'] as num).toInt(),
      previewText: json['previewText'] as String,
      learningObjectives: (json['learningObjectives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isFree: json['isFree'] as bool,
      isFeatured: json['isFeatured'] as bool,
      viewCount: (json['viewCount'] as num).toInt(),
      moderationStatus:
          $enumDecodeNullable(
            _$ModerationStatusEnumMap,
            json['moderationStatus'],
          ) ??
          ModerationStatus.pending,
      moderationComment: json['moderationComment'] as String?,
      moderatedBy: json['moderatedBy'] as String?,
      moderatedAt: json['moderatedAt'] == null
          ? null
          : DateTime.parse(json['moderatedAt'] as String),
    );

Map<String, dynamic> _$EducationalMaterialToJson(
  _EducationalMaterial instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'authorAvatar': instance.authorAvatar,
  'type': _$MaterialTypeEnumMap[instance.type]!,
  'subject': instance.subject,
  'grade': instance.grade,
  'price': instance.price,
  'currency': instance.currency,
  'thumbnailUrl': instance.thumbnailUrl,
  'fileUrls': instance.fileUrls,
  'downloads': instance.downloads,
  'rating': instance.rating,
  'reviewCount': instance.reviewCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isPublished': instance.isPublished,
  'tags': instance.tags,
  'language': instance.language,
  'fileSize': instance.fileSize,
  'fileFormat': instance.fileFormat,
  'difficulty': _$MaterialDifficultyEnumMap[instance.difficulty]!,
  'estimatedTime': instance.estimatedTime,
  'previewText': instance.previewText,
  'learningObjectives': instance.learningObjectives,
  'isFree': instance.isFree,
  'isFeatured': instance.isFeatured,
  'viewCount': instance.viewCount,
  'moderationStatus': _$ModerationStatusEnumMap[instance.moderationStatus]!,
  'moderationComment': instance.moderationComment,
  'moderatedBy': instance.moderatedBy,
  'moderatedAt': instance.moderatedAt?.toIso8601String(),
};

const _$MaterialTypeEnumMap = {
  MaterialType.presentation: 'presentation',
  MaterialType.test: 'test',
  MaterialType.notes: 'notes',
  MaterialType.worksheet: 'worksheet',
  MaterialType.lessonPlan: 'lesson_plan',
  MaterialType.video: 'video',
  MaterialType.audio: 'audio',
  MaterialType.interactive: 'interactive',
};

const _$MaterialDifficultyEnumMap = {
  MaterialDifficulty.beginner: 'beginner',
  MaterialDifficulty.intermediate: 'intermediate',
  MaterialDifficulty.advanced: 'advanced',
};

const _$ModerationStatusEnumMap = {
  ModerationStatus.pending: 'pending',
  ModerationStatus.approved: 'approved',
  ModerationStatus.rejected: 'rejected',
};
