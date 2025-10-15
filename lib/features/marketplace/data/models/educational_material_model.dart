import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/educational_material.dart';

part 'educational_material_model.freezed.dart';
part 'educational_material_model.g.dart';

@freezed
abstract class EducationalMaterialModel with _$EducationalMaterialModel {
  const factory EducationalMaterialModel({
    required String id,
    required String title,
    required String description,
    required String authorId,
    required String authorName,
    required String authorAvatar,
    required String type,
    required String subject,
    required String grade,
    required double price,
    required String currency,
    required String thumbnailUrl,
    required List<String> fileUrls,
    required int downloads,
    required double rating,
    required int reviewCount,
    required String createdAt,
    required String updatedAt,
    required bool isPublished,
    required List<String> tags,
    required String language,
    required int fileSize,
    required String fileFormat,
    required String difficulty,
    required int estimatedTime,
    required String previewText,
    required List<String> learningObjectives,
    required bool isFree,
    required bool isFeatured,
    required int viewCount,
    @Default('pending') String moderationStatus,
    String? moderationComment,
    String? moderatedBy,
    String? moderatedAt,
  }) = _EducationalMaterialModel;

  factory EducationalMaterialModel.fromJson(Map<String, dynamic> json) =>
      _$EducationalMaterialModelFromJson(json);

  static EducationalMaterial toEntity(EducationalMaterialModel model) {
    return EducationalMaterial(
      id: model.id,
      title: model.title,
      description: model.description,
      authorId: model.authorId,
      authorName: model.authorName,
      authorAvatar: model.authorAvatar,
      type: MaterialType.values.firstWhere(
        (e) => e.name == model.type,
        orElse: () => MaterialType.notes,
      ),
      subject: model.subject,
      grade: model.grade,
      price: model.price,
      currency: model.currency,
      thumbnailUrl: model.thumbnailUrl,
      fileUrls: model.fileUrls,
      downloads: model.downloads,
      rating: model.rating,
      reviewCount: model.reviewCount,
      createdAt: DateTime.parse(model.createdAt),
      updatedAt: DateTime.parse(model.updatedAt),
      isPublished: model.isPublished,
      tags: model.tags,
      language: model.language,
      fileSize: model.fileSize,
      fileFormat: model.fileFormat,
      difficulty: MaterialDifficulty.values.firstWhere(
        (e) => e.name == model.difficulty,
        orElse: () => MaterialDifficulty.beginner,
      ),
      estimatedTime: model.estimatedTime,
      previewText: model.previewText,
      learningObjectives: model.learningObjectives,
      isFree: model.isFree,
      isFeatured: model.isFeatured,
      viewCount: model.viewCount,
      moderationStatus: ModerationStatus.values.firstWhere(
        (e) => e.name == model.moderationStatus,
        orElse: () => ModerationStatus.pending,
      ),
      moderationComment: model.moderationComment,
      moderatedBy: model.moderatedBy,
      moderatedAt: model.moderatedAt != null 
          ? DateTime.parse(model.moderatedAt!)
          : null,
    );
  }
}

