// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'educational_material_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EducationalMaterialModel _$EducationalMaterialModelFromJson(
  Map<String, dynamic> json,
) => _EducationalMaterialModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  authorId: json['authorId'] as String,
  authorName: json['authorName'] as String,
  authorAvatar: json['authorAvatar'] as String,
  type: json['type'] as String,
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
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  isPublished: json['isPublished'] as bool,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  language: json['language'] as String,
  fileSize: (json['fileSize'] as num).toInt(),
  fileFormat: json['fileFormat'] as String,
  difficulty: json['difficulty'] as String,
  estimatedTime: (json['estimatedTime'] as num).toInt(),
  previewText: json['previewText'] as String,
  learningObjectives: (json['learningObjectives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isFree: json['isFree'] as bool,
  isFeatured: json['isFeatured'] as bool,
  viewCount: (json['viewCount'] as num).toInt(),
  moderationStatus: json['moderationStatus'] as String? ?? 'pending',
  moderationComment: json['moderationComment'] as String?,
  moderatedBy: json['moderatedBy'] as String?,
  moderatedAt: json['moderatedAt'] as String?,
);

Map<String, dynamic> _$EducationalMaterialModelToJson(
  _EducationalMaterialModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'authorAvatar': instance.authorAvatar,
  'type': instance.type,
  'subject': instance.subject,
  'grade': instance.grade,
  'price': instance.price,
  'currency': instance.currency,
  'thumbnailUrl': instance.thumbnailUrl,
  'fileUrls': instance.fileUrls,
  'downloads': instance.downloads,
  'rating': instance.rating,
  'reviewCount': instance.reviewCount,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'isPublished': instance.isPublished,
  'tags': instance.tags,
  'language': instance.language,
  'fileSize': instance.fileSize,
  'fileFormat': instance.fileFormat,
  'difficulty': instance.difficulty,
  'estimatedTime': instance.estimatedTime,
  'previewText': instance.previewText,
  'learningObjectives': instance.learningObjectives,
  'isFree': instance.isFree,
  'isFeatured': instance.isFeatured,
  'viewCount': instance.viewCount,
  'moderationStatus': instance.moderationStatus,
  'moderationComment': instance.moderationComment,
  'moderatedBy': instance.moderatedBy,
  'moderatedAt': instance.moderatedAt,
};
