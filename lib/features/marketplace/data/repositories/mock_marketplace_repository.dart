import 'package:fpdart/fpdart.dart';
import '../../domain/entities/educational_material.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/repositories/marketplace_repository.dart';

class MockMarketplaceRepository implements MarketplaceRepository {
  @override
  Future<Either<String, List<EducationalMaterial>>> getMaterials({
    FilterOptions? filters,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(_generateMockMaterials(limit));
  }

  @override
  Future<Either<String, EducationalMaterial>> getMaterialById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(_generateMockMaterials(1).first);
  }

  @override
  Future<Either<String, List<EducationalMaterial>>> getFeaturedMaterials() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(_generateMockMaterials(5));
  }

  @override
  Future<Either<String, List<EducationalMaterial>>> getRecommendedMaterials(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(_generateMockMaterials(10));
  }

  @override
  Future<Either<String, List<EducationalMaterial>>> getMaterialsByAuthor(String authorId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(_generateMockMaterials(8));
  }

  @override
  Future<Either<String, List<Review>>> getMaterialReviews(String materialId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right([]);
  }

  @override
  Future<Either<String, Review>> addReview(Review review) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(review);
  }

  @override
  Future<Either<String, bool>> purchaseMaterial(String materialId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(true);
  }

  @override
  Future<Either<String, bool>> downloadMaterial(String materialId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(true);
  }

  @override
  Future<Either<String, List<String>>> getSubjects() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const Right(['Math', 'Science', 'English', 'History']);
  }

  @override
  Future<Either<String, List<String>>> getGrades() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const Right(['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4']);
  }

  @override
  Future<Either<String, bool>> reportMaterial(String materialId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(true);
  }

  List<EducationalMaterial> _generateMockMaterials(int count) {
    return List.generate(count, (index) {
      return EducationalMaterial(
        id: 'material_$index',
        title: 'Educational Material ${index + 1}',
        description: 'This is a sample educational material for testing purposes. It contains high-quality content.',
        authorId: 'author_${index % 3}',
        authorName: 'Teacher ${index % 3 + 1}',
        authorAvatar: 'https://via.placeholder.com/150',
        type: [MaterialType.presentation, MaterialType.notes, MaterialType.worksheet][index % 3],
        subject: ['Math', 'Science', 'English'][index % 3],
        grade: 'Grade ${(index % 4) + 1}',
        price: (index + 1) * 5.0,
        currency: 'USD',
        rating: 4.0 + (index % 10) / 10,
        reviewCount: 10 + (index * 5),
        thumbnailUrl: 'https://via.placeholder.com/300x200',
        fileUrls: ['https://via.placeholder.com/600x400'],
        fileSize: 1024 * 1024 * (index + 1),
        fileFormat: 'PDF',
        downloads: 100 + (index * 20),
        createdAt: DateTime.now().subtract(Duration(days: index)),
        updatedAt: DateTime.now().subtract(Duration(days: index)),
        isPublished: true,
        tags: ['educational', 'quality'],
        language: 'en',
        difficulty: [MaterialDifficulty.beginner, MaterialDifficulty.intermediate, MaterialDifficulty.advanced][index % 3],
        estimatedTime: 30 + (index * 10),
        previewText: 'This is a preview of the material content...',
        learningObjectives: ['Objective 1', 'Objective 2'],
        isFree: index % 4 == 0,
        isFeatured: index < 3,
        viewCount: 500 + (index * 50),
      );
    });
  }
}
